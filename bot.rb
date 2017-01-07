require 'sinatra/base'
require 'slack-ruby-client'

# This class contains all of the logic for loading, cloning and updating the tutorial message attachments.
class SlackTutorial
  # Store the welcome text for use when sending and updating the tutorial messages
  def self.welcome_text
    "Welcome to Slack! We're so glad you're here.\nGet started by completing the steps below."
  end

  # Load the tutorial JSON file into a hash
  def self.tutorial_json
    tutorial_file = File.read('welcome.json')
    tutorial_json = JSON.parse(tutorial_file)
    attachments = tutorial_json["attachments"]
  end

  # Store the index of each tutorial section in TUTORIAL_JSON for easy reference later
  def self.items
    { reaction: 0, pin: 1, share: 2 }
  end

  # Return a new copy of tutorial_json so each user has their own instance
  def self.new
    self.tutorial_json.deep_dup
  end

  # This is a helper function to update the state of tutorial items
  # in the hash shown above. When the user completes an action on the
  # tutorial, the item's icon will be set to a green checkmark and
  # the item's border color will be set to blue
  def self.update_item(team_id, user_id, item_index)
    # Update the tutorial section by replacing the empty checkbox with the green
    # checkbox and updating the section's color to show that it's completed.
    tutorial_item = $teams[team_id][user_id][:tutorial_content][item_index]
    tutorial_item['text'].sub!(':white_large_square:', ':white_check_mark:')
    tutorial_item['color'] = '#439FE0'
  end
end

# This class contains all of the webserver logic for processing incoming requests from Slack.
class API < Sinatra::Base
  # This is the endpoint Slack will post Event data to.
  post '/events' do
    # Extract the Event payload from the request and parse the JSON
    request_data = JSON.parse(request.body.read)
    # Check the verification token provided with the request to make sure it matches the verification token in
    # your app's setting to confirm that the request came from Slack.
    unless SLACK_CONFIG[:slack_verification_token] == request_data['token']
      halt 403, "Invalid Slack verification token received: #{request_data['token']}"
    end

    case request_data['type']
      # When you enter your Events webhook URL into your app's Event Subscription settings, Slack verifies the
      # URL's authenticity by sending a challenge token to your endpoint, expecting your app to echo it back.
      # More info: https://api.slack.com/events/url_verification
      when 'url_verification'
        request_data['challenge']

      when 'event_callback'
        # Get the Team ID and Event data from the request object
        team_id = request_data['team_id']
        event_data = request_data['event']

        # Events have a "type" attribute included in their payload, allowing you to handle different
        # Event payloads as needed.
        case event_data['type']
          when 'team_join'
            # Event handler for when a user joins a team
            Events.user_join(team_id, event_data)
          when 'reaction_added'
            # Event handler for when a user reacts to a message or item
            Events.reaction_added(team_id, event_data)
          when 'pin_added'
            # Event handler for when a user pins a message
            Events.pin_added(team_id, event_data)
          when 'message'
            # Event handler for messages, including Share Message actions
            Events.message(team_id, event_data)
          else
            # In the event we receive an event we didn't expect, we'll log it and move on.
            puts "Unexpected event:\n"
            puts JSON.pretty_generate(request_data)
        end
        # Return HTTP status code 200 so Slack knows we've received the Event
        status 200
    end
  end
end

# This class contains all of the Event handling logic.
class Events
  # You may notice that user and channel IDs may be found in
  # different places depending on the type of event we're receiving.

  # A new user joins the team
  def self.user_join(team_id, event_data)
    user_id = event_data['user']['id']
    # Store a copy of the tutorial_content object specific to this user, so we can edit it
    $teams[team_id][user_id] = {
      tutorial_content: SlackTutorial.new
    }
    # Send the user our welcome message, with the tutorial JSON attached
    self.send_response(team_id, user_id)
  end

  # A user reacts to a message
  def self.reaction_added(team_id, event_data)
    user_id = event_data['user']
    if $teams[team_id][user_id]
      channel = event_data['item']['channel']
      ts = event_data['item']['ts']
      SlackTutorial.update_item(team_id, user_id, SlackTutorial.items[:reaction])
      self.send_response(team_id, user_id, channel, ts)
    end
  end

  # A user pins a message
  def self.pin_added(team_id, event_data)
    user_id = event_data['user']
    if $teams[team_id][user_id]
      channel = event_data['item']['channel']
      ts = event_data['item']['message']['ts']
      SlackTutorial.update_item(team_id, user_id, SlackTutorial.items[:pin])
      self.send_response(team_id, user_id, channel, ts)
    end
  end

  def self.message(team_id, event_data)
    user_id = event_data['user']
    # Don't process messages sent from our bot user
    unless user_id == $teams[team_id][:bot_user_id]

      # This is where our `message` event handlers go:

      # SHARED MESSAGE EVENT
      # To check for shared messages, we must check for the `attachments` attribute
      # and see if it contains an `is_shared` attribute.
      if event_data['attachments'] && event_data['attachments'].first['is_share']
        # We found a shared message
        user_id = event_data['user']
        ts = event_data['attachments'].first['ts']
        channel = event_data['channel']
        # Update the `share` section of the user's tutorial
        SlackTutorial.update_item( team_id, user_id, SlackTutorial.items[:share])
        # Update the user's tutorial message
        self.send_response(team_id, user_id, channel, ts)
      end
    end
  end

  # Send a response to an Event via the Web API.
  def self.send_response(team_id, user_id, channel = user_id, ts = nil)
    # `ts` is optional, depending on whether we're sending the initial
    # welcome message or updating the existing welcome message tutorial items.
    # We open a new DM with `chat.postMessage` and update an existing DM with
    # `chat.update`.
    if ts
      $teams[team_id]['client'].chat_update(
        as_user: 'true',
        channel: channel,
        ts: ts,
        text: SlackTutorial.welcome_text,
        attachments: $teams[team_id][user_id][:tutorial_content]
      )
    else
      $teams[team_id]['client'].chat_postMessage(
        as_user: 'true',
        channel: channel,
        text: SlackTutorial.welcome_text,
        attachments: $teams[team_id][user_id][:tutorial_content]
      )
    end
  end

end

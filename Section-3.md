## Section 3: Event Handlers
**Previous [Section 2: App Configuration](Section-2.md)**  

### Add a URL Verification event handler
On the **Event Subscription** page of your app's settings, you'll see **Request URL**. This is the URL Slack is going to send event data to. In
this example, we're using `/events`. When you enter the URL, Slack is going to make a request to your server to verify it's existence. To do this, Slack will be
sending a `challenge` token.

>![request url](https://cloud.githubusercontent.com/assets/32463/20366597/b411042e-ac00-11e6-92ce-fc49940b5786.png)

>![url verified](https://cloud.githubusercontent.com/assets/32463/20366593/b40d14a4-ac00-11e6-8413-b473c16ef997.png)

The payload of that request will look similar to this:
```json
{
    "token": "abcdefghijklmnopqrstuvwxyz",
    "challenge": "abcdefghijklmnopqrstuvwxyz1234567890",
    "type": "url_verification"
}
```

Our app will need to respond to this request by echoing back the challenge string provided by Slack. We'll need a server object, in this case we're
using Sinatra. Inside of the server class (API), we need a listener for POST requests to our events endpoint, `/events`. We'll need to extract
the `url_verification` challenge token from the request payload. All of these steps together form a complete listener for the `url_verification`
event:

```ruby
class API < Sinatra::Base
  # This is the endpoint Slack will send event data to
  post '/events' do
    # Grab the body of the request and parse it as JSON
    request_data = JSON.parse(request.body.read)
    # The request contains a `type` attribute
    # which can be one of many things, in this case,
    # we only care about `url_verification` events.
    case request_data['type']
    when 'url_verification'
      # When we receive a `url_verification` event, we need to
      # return the same `challenge` value sent to us from Slack
      # to confirm our server's authenticity.
      request_data['challenge']
    end
  end
end
```
More info: https://api.slack.com/events/url_verification

### Add the other event handlers
This bot will be listening for 4 events: messages, pins, reactions and joins. Each of these events contains a
different payload object, so there will be some specific logic for each event.

Our event handlers are within the `Events` class in [bot.rb](./bot.rb#L92) (line 92). This class handles all of the event processing logic so
that it doesn't clutter up the API class. We'll need to reference the event-specific methods inside the event class when an event is received.
We'll add these to the switch statement we added to the API class earlier.

This bot will take action on `team_join`, `reaction_added` and `pin_added` and `message` events.

When a user joins a team, sends a message, adds or removed a reaction emoji, Slack will post a request to our `/events` endpoint. The JSON payload for the `user_join` event looks like this:

```json
  {
      "token": "v3rific4ti0nt0k3n",
      "team_id": "T2UT3AM",
      "api_app_id": "12345678.12345678",
      "event": {
          "type": "team_join",
          "user": {
              "id": "U2XU53R",
              "team_id": "T2UT3AM",
              "name": "@sally",
              "deleted": false,
              "status": null,
              "real_name": "Sally Slackuser",
              "profile": {
                  "first_name": "Sally",
                  "last_name": "Slackuser",
                  "real_name": "Sally Slackuser",
                  "real_name_normalized": "Sally Slackuser"
              },
              "is_bot": false
          }
      },
      "type": "event_callback",
      "authed_users": ["U2XU53R"]
  }
```

This event data structure varies a little between events, but it's basically split into `request` data and `event` data. Request data contains things like the
app ID, verification token, etc. Event data is a subset of the request data, under `event` and contains attributes specific to each event.

From that JSON payload, We'll need to grab a few parameters in order to welcome the user and send them the tutorial message.

Here's a simplified example from [bot.rb](./bot.rb#L68) showing just the `team_join` event:
```ruby
# This class contains all of the web server logic for processing incoming requests from Slack.
class API < Sinatra::Base
  # This is the endpoint Slack will post event data to.
  post '/events' do
    # Extract the event payload from the request and parse the JSON
    request_data = JSON.parse(request.body.read)

    case request_data['type']
      when 'event_callback'
        # Get the Team ID and event data from the request object
        team_id = request_data['team_id']
        event_data = request_data['event']

        # Events have a "type" attribute included in their payload, allowing you to handle different
        # event payloads as needed.
        case event_data['type']
          when 'url_verification'
            # When we receive a `url_verification` event, we need to
            # return the same `challenge` value sent to us from Slack
            # to confirm our server's authenticity.
            request_data['challenge']
          end
          when 'team_join'
            # Event handler for when a user joins a team
            Events.user_join(team_id, event_data)
          else
            # In the event we receive an event we didn't expect, we'll log it and move on.
            puts "Unexpected event:\n"
            puts JSON.pretty_generate(request_data)
          end
        end
        # Return HTTP status code 200 so Slack knows we've received the event
        status 200
    end
  end
end

class Events
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

  def self.message(team_id, event_data)
    # Message share events are posted as a message with an attachment object
    # attached. The first item (and only, in this context) is the original
    # welcome message we sent the user.
    if event_data['attachments']
      if event_data['attachments'].first['is_share']
        user_id = event_data['user']
        ts = event_data['attachments'].first['ts']
        channel = event_data['channel']
        SlackTutorial.update_item( team_id, user_id, SlackTutorial.items[:share])
        self.send_response(team_id, user_id, channel, ts)
      end
    end
  end

end

```

In [bot.rb](./bot.rb#L67), you'll see example handlers for all of the events listed above.

---
**Next [Section 4: Running and Installing Your App](Section-4.md)**  

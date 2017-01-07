## Section 4: Running and Installing your app
**Previous [Section 3: Event Handlers](Section-3.md)**   

### Set Your Environment Variables and Start the Server
On your app's **Basic Information** page, you'll see two fields labeled **Client ID**, **Client Secret** and **Verification Token**. Your
Client ID will be used to identify your app any time you make a request to Slack's APIs. The Client Secret is used during the OAuth
negotiation process to validate your app's authenticity and the Verification token will be used by your server to verify that requests are
coming from Slack.

>![app credentials](https://cloud.githubusercontent.com/assets/32463/20445302/61ddfc54-ad89-11e6-8523-245a60c875b0.png)

 * Assign your app's tokens and verification code to environmental variables. These values are available on your app's **Basic Information**
 page.
  * `export SLACK_CLIENT_ID="XXXX.XXXX"`
  * `export SLACK_API_SECRET="XXXX"`
  * `export SLACK_VERIFICATION_TOKEN="XXXX"`

* Set the OAuth redirect URL using the URL listed in your app's **OAuth & Permissions** settings.
  * `export SLACK_REDIRECT_URI="XXXX"`

* Install the required gems using bundler `bundle install`
* Start the app by calling `rackup`

### Go back and add your Request URL
Using the publicly accessible URL provided by ngrok, something like `https://h7465j.ngrok.io/`, our event endpoint will be
 `https://h7465j.ngrok.io/events`.

 Enter this URL in the **Request URL** field on your app's **Event Subscriptions** page.

>![request url](https://cloud.githubusercontent.com/assets/32463/20366597/b411042e-ac00-11e6-92ce-fc49940b5786.png)

>![url verified](https://cloud.githubusercontent.com/assets/32463/20366593/b40d14a4-ac00-11e6-8413-b473c16ef997.png)

### Installing The App
Once all of our app's functionality is in place, we can go ahead and install the app on our team. :tada:

Visit your app's [/auth/start](http://0.0.0.0:9292) page and click the "Add to Slack" button to begin the OAuth flow. When you
click the button, you'll be directed to Slack's auth request page, where a user specifies a team and agrees to grant access for
the items specified in the app's desired scope. In this demo, we're only using the `bot` scope.

You can read more about Slack's OAuth Scopes [here](https://api.slack.com/docs/oauth-scopes).

Once your app has been authorized, Slack will begin sending Events relevant to your bot to your `/events` endpoint. :clap:

#### Your bot should now be able to see when new users join your team and welcome them with our snazzy onboarding tutorial :tada:
>![onboarding](https://cloud.githubusercontent.com/assets/32463/20369171/690028d2-ac0c-11e6-95a1-c3078762fddd.gif)

### Bonus: Adding additional event handlers
Let's say we wanted to add an additional event handler for responding when a user says "Hello" to our bot in DM. You'd start by looking at the incoming message content to see whether it contains a greeting.

The `message` event contains a `text` attribute. We can scan the contents of that text to see if it contains a greeting like so:
```ruby
  event_data['text'].scan(/hi|hello|greetings/i).any?
```

Once we determine whether the message text contains a greeting, we simply call the `chat_postMessage` method and send a greeting back to the user. :smile:

```ruby
  # INCOMING GREETING
  # We only care about message events with text and only if that text contains a greeting.
  if event_data['text'] && event_data['text'].scan(/hi|hello|greetings/i).any?
    # If the message does contain a greeting, say "Hello" back to the user.
    $teams[team_id]['client'].chat_postMessage(
      as_user: 'true',
      channel: user_id,
      text: "Hello <@#{user_id}>!"
    )
  end
```

Here's what it looks like with the rest of our message event handlers in **[bot.rb](./bot.rb#L129-L174)**:

```ruby
def self.message(team_id, event_data)
  user_id = event_data['user']
  # Don't process messages sent from our bot user
  unless user_id == $teams[team_id][:bot_user_id]

    # This is where our `message` event handlers go:

    # INCOMING GREETING
    # We only care about message events with text and only if that text contains a greeting.
    if event_data['text'] && event_data['text'].scan(/hi|hello|greetings/i).any?
      # If the message does contain a greeting, say "Hello" back to the user.
      $teams[team_id]['client'].chat_postMessage(
        as_user: 'true',
        channel: user_id,
        text: "Hello <@#{user_id}>!"
      )
    end

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
```

---

## Feedback
I'd love to hear your feedback on this example. You can file an issue, submit a PR or message me on either of these:

GitHub: [roach](https://github.com/roach) Twitter: [@roach](https://twitter.com/roach)

---
**Go back to [README](README.md)**  

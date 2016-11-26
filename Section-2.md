## Section 2: App Configuration
**Previous [Section 1: Getting Started](Section-1.md)**  

### OAuth & Permissions
Slack uses OAuth for user authentication. This auth process is performed by exchanging a set of keys and tokens between Slack's servers and yours. This process allows the authorizing user to confirm that they want to grant our bot access to their team.

To keep this tutorial simple, I've already built out the OAuth flow for you. The code can be found in **[auth.rb](./auth.rb)**. You can read up on Slack's OAuth flow here: https://api.slack.com/docs/oauth.

>![oauth](https://cloud.githubusercontent.com/assets/32463/20575277/789c0c5a-b16d-11e6-86fd-e30c3a0d2e61.gif)

The final step of this process is redirecting the user back to your completion page. This URL is called the **Redirect URL**. Add your OAuth redirect URL to your app's **OAuth & Permissions** page. This URL will be your ngrok URL with the `/finish_auth` endpoint (e.g. https&#8203;://h7465j.ngrok.io/finish_auth).

>![oauth redirect  url](https://cloud.githubusercontent.com/assets/32463/20543629/63e41a26-b0bb-11e6-8eee-90c6f4f1dbb1.png)

### Add a Bot User
You'll need to add a **bot user** so that your app can interact with users. Go to your app's settings and locate the **Bot Users** section to add your bot user.

>![bot user](https://cloud.githubusercontent.com/assets/32463/20371297/9044e2a0-ac18-11e6-8f25-3ffbd8a3bf58.png)

### Event Subscriptions
First, Enable events:  
>![enable events](https://cloud.githubusercontent.com/assets/32463/20549612/e7ee2ed4-b0e2-11e6-8b9c-01ed08057c7c.png)

Then, subscribe to these **Bot Events**:
* [message.im](https://api.slack.com/events/message.im)
* [pin_added](https://api.slack.com/events/pin_added)
* [reaction_added](https://api.slack.com/events/reaction_added)
* [team_join](https://api.slack.com/events/team_join)

Your bot's Event Subscriptions should look like this:
>![bot events](https://cloud.githubusercontent.com/assets/32463/20366596/b40ffbc4-ac00-11e6-9626-6356be5612f8.png)

Remember to save your changes.

---
**Next [Section 3: Event Handlers](Section-3.md)**  

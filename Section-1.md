
## Section 1: Getting Started
**Previous [README](README.md)**  

### Create a New App on  [api.slack.com](https://api.slack.com/apps)
Visit https://api.slack.com/apps and click the `Create New App` button, fill out the name, team, etc and create the app. Don't worry
about the credentials for now, we'll be revisiting this page later.
> ![create a new app](https://cloud.githubusercontent.com/assets/32463/20549718/afdd98d0-b0e3-11e6-8d83-8ad7053deb80.png)

### Create A Tunnel Using ngrok
This may seem like a weird thing to begin with, but you're going to need to know your ngrok URL as we go through the setup steps.

Start ngrok so you'll have the ngrok.io URL for use in your app configuration. Ngrok will allow your server to be publicly accessible.

In your terminal, run `ngrok http 9292` (_Note: 9292 is Sinatra's default HTTP port, be sure to update this command if you change it_)

Once running, ngrok will output your server's URLs:

```bash
ngrok by @inconshreveable (Ctrl+C to quit)

Session status                      online
Version                             2.1.18
Region                  United States (us)
Web Interface        http://127.0.0.1:4040

Forwarding http://h7465j.ngrok.io -> localhost:9292
Forwarding https://h7465j.ngrok.io -> localhost:9292
```
You want the HTTPS URL listed by ngrok. (ex. https://h7465j.ngrok.io)

The ngrok Web Interface provides stats about your server and allows you to inspect incoming request payloads: http://127.0.0.1:4040.

---
**Next [Section 2: App Configuration](Section-2.md)**  

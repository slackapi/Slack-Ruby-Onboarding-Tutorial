### Building an onboarding bot in Ruby using Slack's [Events API](https://api.slack.com/events-api)
This example demonstrates what it takes to build a Slack bot in Ruby. We'll cover the steps
required to create and configure your app, set up event subscriptions, and add event handlers.

We're going to build an onboarding bot to welcome new users to your team and guide them in interacting with Slack messages.

Something like this:
>![onboarding](https://cloud.githubusercontent.com/assets/32463/20369171/690028d2-ac0c-11e6-95a1-c3078762fddd.gif)

Don't worry, you can do this. I believe in you. :star2:

---

## Technical Requirements  
Since this example was written in Ruby, you'll need to have Ruby installed. We're using 2.3, specifically. We're also going to use a few Ruby
gems to help us out, so you'll need those too.

### Code / Libraries Required
* [Ruby](https://www.ruby-lang.org/) - the programming language we're going to write the app in
* [Bundler](http://bundler.io/) - the Ruby package manager we'll be using to make sure we have everything we need
* [Sinatra](http://www.sinatrarb.com/) - a fairly lightweight web server for Ruby
* [slack-ruby-client](https://github.com/slack-ruby/slack-ruby-client/) - an awesome Ruby Slack client maintained by [dblock](https://github.com/dblock)

First, make sure you have the correct version of Ruby installed and upgrade or install Ruby if necessary. You can check your Ruby version by running `ruby -v`. If you have a version less than 2.3, you'll want to upgrade. If you need to keep your older version and run multiple versions, you can use [RVM](https://github.com/rvm/rvm) or [rbenv](https://github.com/rbenv/rbenv).

Once you know you have the correct Ruby version, install Bundler by running `gem install bundler`.

After installing Bundler, you can use Bundler to install the required gems from our [Gemfile](./Gemfile) by running `bundle install`.

You should see some output similar to this:
```bash
  Using sinatra 1.4.7
  Using slack-ruby-client 0.7.7
  Bundle complete! 2 Gemfile dependencies, 20 gems now installed.
  Use `bundle show [gemname]` to see where a bundled gem is installed.
```
There will probably be more gems listed, as each of the gems we're using have their own dependencies. As long as it ends with `Bundle complete!` and not an error, you should be good.

### Server Requirements
Since Slack will be delivering events to you, you'll need a server which is capable of receiving incoming HTTPS traffic from Slack.

When running this project locally, you'll need to set up tunnels so that Slack can post requests to your endpoints. I recommend a
tool called [ngrok](https://ngrok.com/). It's easy to use and supports HTTPS, which is required by Slack.

To test these events coming to your server without going through the actions in a Slack app, you can use something like
[Postman](https://www.getpostman.com/) to recreate the requests sent from Slack to your server. This is especially helpful
for events like user join, where the workflow to recreate the event is rather complex.

## Suggested Reading Material

### Explore the source code files
Much of the documentation for this project will be found in the source code itself, so you'll want to read through them. I recommend going through them in this order:

1. **[config.ru](./config.ru)** is the rack config file. This tells the server what objects (Auth and Bot) to create and run.  
2. **[auth.rb](./auth.rb)** is where we'll handle the OAuth authentication flow. In order to access a team's events and data, we need to ask the
user for permission to install the app on their Team and to grant our bot user access.  
3. **[bot.rb](./bot.rb)** is where all of the event logic lives, where you'll find the handlers to actually process and respond to
events.
4. **[welcome.json](./welcome.json)** This is a JSON file of message attachments used to create the onboarding welcome message our bot will send to new users.

### Documentation
* [Getting started with Slack apps](https://api.slack.com/slack-apps)  
* [Slack Events API documentation](https://api.slack.com/events)  
* [Slack Web API documentation](https://api.slack.com/web)

## Let's get started :tada:
**[Section 1: Getting Started](Section-1.md)** :point_left:  
[Section 2: App Configuration](Section-2.md)  
[Section 3: Event Handlers](Section-3.md)  
[Section 4: Running and Installing Your App](Section-4.md)

## Where to Find Help
Wondering what to do if you can't get this dang tutorial to work for you? The Slack Developer community is an awesome place to get help when
you're confused or stuck. We have an excellent 'search first' culture and Slack is committed to improving our tutorials and documentation
based on your feedback. If you've checked the [Slack API documentation](https://api.slack.com/), reached the end of your google patience and
found [StackOverflow](http://stackoverflow.com/questions/tagged/slack-api) to be unhelpful, try asking for help in the
[Dev4Slack](http://dev4slack.xoxco.com/) Slack team.

---

## Feedback
I'd love to hear your feedback on this example. You can file an issue, submit a PR or message me on GitHub ([roach](https://github.com/roach)) or Twitter ([@roach](https://twitter.com/roach)).

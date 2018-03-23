# BugMeister

A Bugmark Research Application 

## Goals

- Generate live trading data ASAP with a ‘standup poker’ style app
- Minimum UI, Limited features, limited functions
- Simple / Hackable / Extensible

## Scenario

- We post a simple webapp for internal use by the bugmark team
- App runs a friendly competition to see who gets high score
- Trading tokens not real currency
- Every week, traders are topped up to a minimum of 1000 tokens
- Users self-register with email and pwd (anyone can register)
- We post leaderboards, top issues, etc. etc. 

## Tooling

- `bmx_cli_ruby` - our ruby cli
- Sinatra - simplistic web-app builder
- Bootstrap4 / FontAwesome / Datatables - loaded via CDN in page layout
- Application data stored in JSON files - no database
- Tested to run on an Ubuntu host
- Repo list hard-coded in a server-side JSON file

## Cron 

- [Weekly] top off user balances
- [Hourly] sync bugs
- [Hourly] cross open offers


# TestBench DevLog

## 2018 Mar 22 WED

- [x] create app
- [x] add sinatra
- [x] add slim
- [x] create layout
- [x] add bootstrap
- [x] add datatables
- [x] add fontawesome
- [x] create nav

## 2018 Mar 28 WED

- [x] add `content_for`
- [x] add datatables
- [x] add issues page

## 2018 Mar 29 THU

- [x] create issue_oracle (iora) gem

## 2018 Apr 06 FRI

- [x] first version of Iora gem working end-to-end
- [x] add iora to CL Gemfile
- [x] add repo/sync to bmx_cl

## 2018 Apr 10 TUE

- [x] add iora fetch executable
- [x] working iora fetch from Github 

## 2018-04-13 FRI

- [x] Add machine-readable data (quotes, trivia, proverbs)

## 2018-04-14 SAT

- [x] Write first-draft exercise methodology

## 2018-04-15 SUN

- [x] Reorganize repo directories
- [x] Create and provision dogfood1.bugmark.net
- [x] Create and provision worker1.bugmark.net

## 2018-04-21 SAT

- [x] Add gen_docs script 

## 2018-04-22 SUN

- [x] Get webapp to connect directly to exchange

## 2018-04-24 TUE

- [x] Add create/update actions to Iora (github and yaml)
- [x] Add gen_exercise script 
- [x] Markdown rendering works

## 2018-04-24 TUE

- [x] create login page
- [x] create 'current_user' method
- [x] create 'logged_in?' method
- [x] create 'authorize' method

## 2018-04-25 WED

- [x] fix gem versioning bug
- [x] create take button
- [x] add offers page
- [x] create help page template
- [x] update exercise title

## 2018-04-25 WED

- [x] add IORA tracker
- [x] add 'link_to_unless_current'
- [x] add All Contracts | My Contracts
- [x] add Offer maturation dates

## 2018-04-25 WED

- [x] show balance and history on account page
- [x] add OPEN/CLOSE actions to IORA tracker
- [x] add comments to the IORA tracker
- [x] update home-page text
- [x] fill out account page
- [x] sync_issues script 
- [x] cron - issue sync
- [x] Add dynamically rendered SVG

## 2018-05-20 SUN

- [x] /contracts - change xtag from "con" to "contract"
- [x] /contract - change title `@contract.xid.capitalize`
- [x] /contracts - show funder count instead of name
- [x] /contract - show list of funders
- [x] /contract  - link to Bugmark issue
- [x] /contracts - link to Bugmark issue
- [x] /contract - get rid of hardcoded "Eastern Time"
- [x] /issues - get rid of "matures"
- [x] /issue - add "Open issue matures" message to offer list
- [x] /issue - add issue status
- [x] /login - fix login count
- [x] /account - add "terms acceptance date" with link to terms
- [x] /badge: make badge render from ISSUE not OFFER
- [x] exchange - add 'synced_at' to issue
- [x] /issue - add last-sync time

- [ ] add .5 pricing
- [ ] add individual offer matching

- [ ] predicate: funding_done?
- [ ] query: number of offers funded since last period
- [ ] #seed_money -> balance - offer_bu.sum
- [ ] #escrow -> TBD
- [ ] #earnings -> TBD
- [ ] successful fundings
- [ ] funding payout: 50 / number of funders

- [ ] /issues - checklist for multi-offer funding

- [ ] /issue - don't allow more than one funding per issue
- [ ] /issue - don't allow accepting your own offer

- [ ] /issues - switch from 'fund an offer' to 'accept offer' per funding obligation
- [ ] /issue - don't allow FUNDING once contract is formed
- [ ] /issue - don't allow FUNDING if insufficient user balance
- [ ] /issue - don't allow ACCEPT OFFER before funding obligation is settled
- [ ] /account - show sources of funds - break out earnings

- [ ] user bubble: show earnings

- [ ] /admin - test sync button
- [ ] /admin - test resolve button
- [ ] system_build - top everyone up to seed_balance
- [ ] clean up documentation...

## TBD

- [ ] TBD

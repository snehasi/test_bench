# Bugmark Test Bench

A framework for Bugmark research exercises.

See our [Google Doc][1] for more info.

[1]: https://docs.google.com/document/d/1Eju-BQK65XL82GG_aT9HddUwh0jZLpR6xKIPxPnAxuo/edit#

How to setup a new exercise (replace `<exercise_name>` with the version of test_bench you use):

- create a file `exercise/<exercise_name>/.env` with the following value:

```
TRIAL_DIR=~/trial/<exercise_name>
```

- make sure to create a folder `~/trial/<exercise_name>`
- setup the cron scripts (how ?)
- create a trial repo (how ?)
  - create on github (how ?)
  - clone locally (how ?)
  - make sure .env file is good (see above)
  - run `trialinit` (in what folder?
  - edit `<TRIAL_DIR>/Settings.yml` (where is a template for the file?)
  

# cli_time_track

Time tracking in yaml file.

There are many ways to track working time,
most of them use GUI or web.
IMHO, it faster and easier to track time in the terminal.

If you use GitLab, you can enter your working time inside the git commit message as

```
/spent 2h
```

Sometimes you need to track time outside of any git commit.

You can track the time in a simple yaml file like this:

```
- 2020-10-29:
  - 1h: upgrade flutter
  - 1h: try deploy to web
  - 30m: parse time.yaml
- 2020-10-30:
  - 2h,15m: create separate repo, write README
```

Running a command ```> ttrack``` will parse the file
and generate more-or-less readable overview of the time spent
per day (during current week) and by week (current month).

```
Loading time.yaml
Current week (daily):
[2020-10-26, Mo, -]
[2020-10-27, Tu, -]
[2020-10-28, We, -]
[2020-10-29, Th, 2 hours 30 minutes]
[2020-10-30, Fr, 2 hours 15 minutes]
[2020-10-31, Sa, -]
[2020-11-01, Su, -]

Current month (weekly):
[W44, 4 hours 45 minutes]
```

# Future plans

* ttrack command should have switches to configure
how many weeks/months should the report go backwards
* maybe rewrite in TypeScript for people without Dart.

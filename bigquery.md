## Google BigQuery
BigQuery is introduced as `Serverless, highly scalable, and cost-effective multicloud data warehouse designed for business agility.`
Due to serverless architecture, it decreases operational/maintenance costs to almost zero, which enables the teachnical team to focus on busoness logic.

I want to also mention that, the most important feature it has is, the power of Standart SQL in reporting field, which reduces the learning curve of new query structure/dialect and technical complexity as well. 
As far as I see from this PoC/research, it eases onboarding and resource sharing a lot.

**IMPORTANT NOTE** Due to Billing Account issues and monthly bucget limitations, I'm not able to showcase the requested work in a running environment, but once can login/register to the sandbox environment and give try to following queries, which will answer the requests from given case.

```sql
 -- Get all column names from dataset
 SELECT
  *
 FROM
  `bigquery-public-data.github_repos.INFORMATION_SCHEMA.COLUMN_FIELD_PATHS`
```

### Get Pull Requests for Repo from archive (day/month/year formats are available) 
**Important Note**: Be careful when running month or year queries, due to high costs.

In [sample-pr-payload](./sample-pr-payload.json) file you can see a sample PullRequest event's details

```sql
SELECT repo.name,
       payload
FROM `githubarchive.day.20190101`
WHERE repo.name = 'grafana/grafana' AND type ='PullRequestEvent' LIMIT 1000;

```

### List of Event Types On BQ Github Dataset
 - `PullRequestEvent`
 - `DeleteEvent`
 - `ForkEvent`
 - `CommitCommentEvent`
 - `PublicEvent`
 - `PushEvent`
 - `CreateEvent`
 - `IssuesEvent`
 - `ReleaseEvent`
 - `PullRequestReviewCommentEvent`
 - `GollumEvent`
 - `MemberEvent`

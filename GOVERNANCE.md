# OpenWebF Project Governance

<!-- TOC -->

* [Collaborators](#collaborators)
  * [Collaborator activities](#collaborator-activities)
  * [Collaborator nominations](#collaborator-nominations)
* [Technical steering committee](#technical-steering-committee)
  * [Establishment TSC](#establishment-tsc)
  * [TSC elections](#tsc-elections)
  * [TSC meetings](#tsc-meetings)
  * [TSC voting](#tsc-voting)

<!-- /TOC -->

## Collaborators

OpenWebF Core Collaborators maintain the [openwebf/webf][] GitHub repository.
The GitHub team for OpenWebF Core Collaborators is @openwebf/collaborators.
Collaborators have:

* Commit access to the [openwebf/webf][] repository
* Access to the OpenWebF continuous integration (CI) jobs

Both Collaborators and non-Collaborators may propose changes to the OpenWebF
source code. The mechanism to propose such a change is a GitHub pull request.
Collaborators review and merge (_land_) pull requests.

Two Collaborators must approve a pull request before the pull request can land.
(One Collaborator approval is enough if the pull request has been open for more
than 7 days.) Approving a pull request indicates that the Collaborator accepts
responsibility for the change. Approval must be from Collaborators who are not
authors of the change.

If a Collaborator opposes a proposed change, then the change cannot land. The
exception is if the TSC votes to approve the change despite the opposition.
Usually, involving the TSC is unnecessary. Often, discussions or further changes
result in Collaborators removing their opposition.

### Collaborator activities

* Helping users and novice contributors
* Contributing code and documentation changes that improve the project
* Reviewing and commenting on issues and pull requests
* Participation in working groups
* Merging pull requests

The TSC can remove inactive Collaborators or provide them with _Emeritus_
status. Emeriti may request that the TSC restore them to active status.

### Collaborator nominations

Existing Collaborators can nominate someone to become a Collaborator. Nominees should have significant and valuable contributions across the OpenWebF organization.

To nominate a new Collaborator, open an issue in the [openwebf/webf][] repository. Provide a summary of the nominee's contributions. For example:

* Commits in the [openwebf/webf][] repository
  * Use the link `https://github.com/openwebf/webf/commits?author=GITHUB_ID`
* Pull requests and issues opened in the [openwebf/webf][] repository
  * Use the link `https://github.com/openwebf/webf/issues?q=author:GITHUB_ID`
* Comments on pull requests and issues in the [openwebf/webf][] repository
  * Use the link `https://github.com/openwebf/webf/issues?q=commenter:GITHUB_ID`
* Reviews on pull requests in the [openwebf/webf][] repository
  * Use the link `https://github.com/openwebf/webf/pulls?q=reviewed-by:GITHUB_ID`
* Pull requests and issues opened throughout the OpenWebF organization
  * Use the link  `https://github.com/search?q=author:GITHUB_ID+org:openwebf`
* Comments on pull requests and issues throughout the OpenWebF organization
  * Use the link `https://github.com/search?q=commenter:GITHUB_ID+org:openwebf`
* Help provided to end-users and novice contributors
* Participation in other projects, teams, and working groups of the OpenWebF organization

Mention @openwebf/collaborators in the issue to notify other Collaborators about the nomination.
The nomination passes if no Collaborators oppose it after one week. Otherwise, the nomination fails.

## Technical Steering Committee

A subset of the Collaborators forms the Technical Steering Committee (TSC). The TSC is responsible for all technical development within the OpenWebF project, including:

* Setting release dates.
* Release quality standards.
* Technical direction.
* Project governance and process (including this policy).
* GitHub repository hosting.
* Conduct guidelines.
* Maintaining the list of additional Collaborators.
* Development process and any coding standards.
* Mediating technical conflicts between Collaborators projects.
* The TSC will define OpenWebF project’s release vehicles.

### Establishment TSC

The TSC members will elect from Collaborators. TSC memberships are not time-limited. There is no maximum size of the TSC. The size is expected to vary in order to ensure adequate coverage of important areas of expertise, balanced with the ability to make decisions efficiently. The TSC must have at least three members.

There is no specific set of requirements or qualifications for TSC membership beyond these rules. The TSC may add additional members to the TSC by a standard TSC motion and vote. A TSC member may be removed from the TSC by voluntary resignation, by a standard TSC motion, or in accordance to the participation rules described below.

Changes to TSC membership should be posted in the agenda, and may be suggested as any other agenda item.

TSC members are expected to regularly participate in TSC activities. If a TSC member does not attend any meeting within three months, the TSC membership will automatically become invalid and removed.

### TSC elections

Leadership roles in the OpenWebF project will be peer elected representatives of the community.

The TSC will elect from amongst voting TSC members a TSC Chairperson to work on building an agenda for TSC meetings.
The TSC shall hold annual elections to select a TSC Chairperson and
there are no limits on the number of terms a TSC Chairperson.

The TSC will elect from amongst voting TSC members a TSC Chairperson to work
on building an agenda for TSC meetings.
The TSC shall hold annual elections to select a TSC Chairperson and
there are no limits on the number of terms a TSC Chairperson.

For election of persons (such as the TSC Chairperson), a multiple-candidate
method should be used, such as:

* [Condorcet][] or
* [Single Transferable Vote][]

Multiple-candidate methods may be reduced to simple election by plurality
when there are only two candidates for one position to be filled. No
election is required if there is only one candidate and no objections to
the candidate's election. Elections shall be done within the projects by
the Collaborators active in the project.

### TSC meetings

The TSC shall meet regularly using tools that enable participation by the community (e.g. weekly on a DingTalk online conference
, or through any other appropriate means selected by the TSC). The meeting shall be directed by the TSC Chairperson. Responsibility for directing individual meetings may be delegated by the TSC Chairperson to any other TSC member. Minutes or an appropriate recording shall be taken and made available to the community through accessible public postings.

The TSC agenda includes issues that are at an impasse. The intention of the
agenda is not to review or approve all patches. Collaborators review and approve
patches on GitHub.

Any community member can create a GitHub issue asking that the TSC review
something. If consensus-seeking fails for an issue, a Collaborator may apply the
`tsc-agenda` label. That will add it to the TSC meeting agenda.

Before each TSC meeting, the meeting chair will share the agenda with members of
the TSC. TSC members can also add items to the agenda at the beginning of each
meeting. The meeting chair and the TSC cannot veto or remove items.

The TSC may invite people to take part in a non-voting capacity.

During the meeting, the TSC chair ensures that someone takes minutes. After the
meeting, the TSC chair ensures that someone opens a pull request with the
minutes.

The TSC seeks to resolve as many issues as possible outside meetings using
[the TSC issue tracker](https://github.com/openwebf/TSC/issues). The process in
the issue tracker is:

* A TSC member opens an issue explaining the proposal/issue and @-mentions
  @openwebf/tsc.
* The proposal passes if, after 72 hours, there are two or more TSC approvals
  and no TSC opposition.
* If there is an extended impasse, a TSC member may make a motion for a vote.

### TSC voting

For internal project decisions, Collaborators shall operate under [Lazy Consensus][].
The TSC shall establish appropriate guidelines for implementing Lazy Consensus
(e.g. expected notification and review time periods) within the development process.

The TSC follows a [Consensus Seeking][] decision making model. When an agenda
item has appeared to reach a consensus the moderator will ask "Does anyone object?"
as a final call for dissent from the consensus.

If an agenda item cannot reach a consensus a TSC member can call for either a
closing vote or a vote to table the issue to the next meeting.
The call for a vote must be seconded by a majority of the TSC or else the discussion will continue.

For all votes, a simple majority of all TSC members for, or against, the issue wins.
A TSC member may choose to participate in any vote through abstention.


[openwebf/webf]: https://github.com/openwebf/webf
[Lazy Consensus]: https://community.apache.org/committers/lazyConsensus.html
[Consensus Seeking]: https://en.wikipedia.org/wiki/Consensus-seeking_decision-making
[Condorcet]: https://en.wikipedia.org/wiki/Condorcet_method
[Single Transferable Vote]: https://en.wikipedia.org/wiki/Single_transferable_vote

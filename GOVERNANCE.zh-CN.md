# OpenWebF 项目协同

<!-- 目录 -->

* [协作者](#协作者)
   * [协作者职责](#协作者职责)
   * [协作者提名](#协作者提名)
* [技术委员会](#技术委员会)
   * [组建委员会](#组建委员会)
   * [委员会选举](#委员会选举)
   * [委员会会议](#委员会会议)
   * [委员会投票](#委员会投票)

<!-- 目录 -->

## 协作者

OpenWebF 的协作者将共同维护 [openwebf/webf] 仓库，协作者在 GitHub 上的小组名称为 @openwebf/collaborators。

协作者拥有以下权限：

* [openwebf/webf] 仓库的 Commit 权限
* OpenWebF 持续集成（CI）任务的权限

无论协作者还是非协作者都可以提交 OpenWebF 的更改，提交更改的机制是通过 Pull Request (PR)。

PR 至少两个协作者 Review 通过后才能 Merge，但如果 PR 已经打开超过 7 天，则获得一个协作者的 Review 通过就可以 Merge。

协作者同意该 PR 表示该协作者接受和承担变更所导致的风险与责任，同时协作者不能同意通过自己提交的 PR。

任何协作者都可反对任何 PR 中的改动，一旦发生，则该 PR 暂时无法 Merge，可以通过讨论或进一步的修改让反对的协作者同意该 PR 中的改动。当僵持无法达成共识时，可以通过在技术委员会里使用 投票的机制来决定。

### 协作者职责

* 帮助新手贡献者
* 贡献代码和更新文档
* 审查和评论 Issue 并提交 Pull Request
* 参加工作组
* 合并 Pull Request

技术委员会可以移除不活跃的协作者或将他们转移到**荣誉组**，荣誉组成员可以让技术委员会将他们恢复为协作者。

### 协作者提名

现有的协作者可以提名某人成为协作者，被提名人应当是在整个 OpenWebF 生态上做出贡献的组织或个人。

要提名新的协作者，需要到 [openwebf/webf][] 仓库中提出一个 Issue，并提供被提名人相关贡献的概述。例如：

* 在 [openwebf/webf][] 仓库中的 Commits
  * 链接格式 `https://github.com/openwebf/webf/commits?author=GITHUB_ID`
* 在 [openwebf/webf][] 仓库中提交的 Pull requests 和 Issues
  * 链接格式 `https://github.com/openwebf/webf/issues?q=author:GITHUB_ID`
* 在 [openwebf/webf][] 仓库中对 Pull requests 和 Issues 的评论
  * 链接格式 `https://github.com/openwebf/webf/issues?q=commenter:GITHUB_ID`
* 在 [openwebf/webf][] 仓库中的 Reviews
  * 链接格式 `https://github.com/openwebf/webf/pulls?q=reviewed-by:GITHUB_ID`
* 在整个 OpenWebF 组织下提交的 Pull requests 和 Issues
  * 链接格式 `https://github.com/search?q=author:GITHUB_ID + org:openwebf`
* 在整个 OpenWebF 组织下对 Pull requests 和 Issues 的评论
  * 链接格式 `https:////github.com/search?q=commenter:GITHUB_ID + org:openwebf`
* 向 OpenWebF 用户和新手贡献者提供的帮助
* 参加 OpenWebF 的其他项目，团队、工作组或组织

在 Issue 中 `@openwebf/collaborators` 以通知其他协作者。如果一周后没有任何协作者反对，则提名通过，否则提名失败。

## 技术委员会

一部分协作者组成了技术委员会（TSC），以下简称委员会。委员会为 OpenWebF 项目内的所有技术开发行为负责，其职责包括：

* 设置发布日期
* 发布质量标准
* 引导技术方向
* 项目管理和流程（包括本政策）
* 管理代码仓库
* 进行技术指导
* 维护协作者列表
* 维护开发过程和任何编码标准
* 协调技术冲突
* 委员会将提供 OpenWebF 项目的发布工具

### 组建委员会

委员会成员将从协作者中选出，委员会成员的任期、人数没有上限。为了保证投票公平，以及覆盖更多专业领域，委员会至少包含 3 名成员。

委员会成员可以通过发起议题或投票的方式进行扩充，也可以自愿退出委员会。

任何委员会成员的变动都应该被记录在委员会会议议程中，并且和其它议程一样，允许对其提出建议和意见。

委员会应当定期参与委员会活动，如果委员会成员三个月内未参加任何会议，则视为自愿退出委员会。

### 委员会选举

委员会将从委员会成员中选出委员会主席，以制定委员会会议议程。委员会将举行年度选举以选举委员会主席，并且委员会主席的任期没有限制。

对于选举人由多名候选人组成，投票机制可以选择的方法有：
* [孔多塞投票法](https://zh.wikipedia.org/wiki/%E5%AD%94%E5%A4%9A%E5%A1%9E%E6%8A%95%E7%A5%A8%E6%B3%95)
* [可转移单票制](https://zh.wikipedia.org/wiki/%E5%8F%AF%E8%BD%89%E7%A7%BB%E5%96%AE%E7%A5%A8%E5%88%B6)

当只有两个候选人匹配一个职位时，可以将多个候选人的方法简化为简单的选举。如果只有一名候选人，并且对该候选人没有异议，则无需选举。选举应由活跃于项目中的协作者中进行。

### 委员会会议

委员会主席召开在线会议与主持会议。委员会议程通常会讨论陷入僵局的 Issue，议程的目的不是 Review 所有 PR，这些 PR 应该由协作者 Review 与 Approve。

任何社区成员都可以创建一个 Issue 请求委员会 Review 内容。如果对于一个 Issue 无法达成共识，则协作者可以增加 `tsc-agenda` 标签，这会将这个问题添加到委员会会议议程中。

在每次委员会会议之前，会议主席将与委员会成员共同制定议程。委员会成员还可以在每次会议开始时将需要讨论的议题添加到议程中。会议主席和其他委员会成员都无法否决或删除讨论的议题。

委员会可以邀请协作者与社区成员参加无投票权的活动。

在会议期间，委员会主席需要确保有人在记录会议纪要。在会议结束后，委员会主席需要保证会议纪要被上传。

委员会可以使用[委员会问题跟踪区](https://github.com/openwebf/TSC/issues) 在会议之外解决尽可能多的问题。 问题跟踪区的运行机制是：

* 委员会成员打开一个问题，解释提案/问题和 @提及
  @openwebf/tsc
* 如果 72 小时后获得两个或更多委员会成员批准，且没有委员会成员的反对，则提案通过
* 如果不能够达成共识，委员会成员可以提出发起投票

### 委员会投票

对于内部项目决策，协作者应在 [Lazy Consensus][] 下进行操作。委员会同时需建立在开发过程中实施 [Lazy Consensus][] 的指南，例如预期的通知和 Review 时间段。

委员会遵循寻 [Consensus Seeking][] 的决策模型。当议程接近达成共识时，主持人会问 “有人反对吗？” 作为对提出异议的最终询问。

如果某个议题暂时无法达成共识，则委员会成员可以要求结束投票表决或将问题搁置到下次会议进行，但如果多数委员会成员反对，则投票将继续进行。

对于所有投票，绝大多数委员会成员同意则该提议通过，委员会成员也可以选择放弃投票。

[openwebf/webf]: https://github.com/openwebf/webf
[Lazy Consensus]: https://community.apache.org/committers/lazyConsensus.html
[Consensus Seeking]: https://en.wikipedia.org/wiki/Consensus-seeking_decision-making

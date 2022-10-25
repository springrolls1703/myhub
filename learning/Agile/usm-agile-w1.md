What is Agile?  
Why is Agile so special?  
Where did Agile come from?  
How are people using "Agile" in the real world?  
---

## 1. What is agile? 

What are the core values?
+ Individuals and Interaction ***over processes and tools.***
+ Working software ***over comprehensive document***
+ Customer Satisfaction ***contract negotiation***
+ Responding to change ***over completing a plan***

Sprint basics  
Planning -> Development -> Review & Retro
1. Planning
- Product backlog: bugs, stories, features
  + Input: Product Backlog of stories prioritized by the Product Owner
  + Process: Review and select stories for the sprint
  + Output: Sprint Backlog of stories the team commits to complete by the end of the Sprint
2. Development
- Structure work based on teams skillsets.
- No clients can change the plan.
- Daily stands up: tell what to be done daily.
- Product Owners builds and priortizes backlog.

  + Input: Sprint Backlog of stories the team commits to complete by the end of the Sprint
  + Process: Daily reporting and execution against a few stories at a time: designing, building, testing and closing
  + Output: A shippable product increment that can be demonstrated
3. Sprint review & Retro
- Team showed the whole outcome to client.
  + Input: Shippable product increment that can be demonstrated
  + Process: Demonstrations and games to facilitate feedback on the product and team processes
  + Output: Feedback on the product's direction and actions to improve the next sprint

### Comparision

1. Agile - varies scope against fixed budget and schedule
2. Traditional - varies budget against fixed scope and schedule
3. Lean - varies schedule (or solution time) against fixed scope and budget


***Agile is a methodology we can defined as:***
- Shared Vision Robust to change.
- Whole teams
- Incremental Delivery
- Continous Integration & Testing

### Misconceptions:
- Charter
- Plan
- Documentation
- Design
- Testing

Evolution of Agile:
TQM > TPS > TOC

### TQM: Total Quality Management
The core tenants of TQM include:
- Improving Quality Decreases Costs - lowers costly defects, customer support, and recalls
- Continuous Improvement - for the systems and people in the systems
- Pride of Workmanship - the primary driver of knowledge workers and source of quality is joy in good work
- Plan-Do-Check-Act  (PDCA) - this cycle allows for testing a complex system that can't be modeled easily

### TPS: The Toyota Production System
- Eliminate 7 Wastes - Movement, Inventory, Motion, Waiting, Overproduction, Over-Processing, Defects
- Small Batches - exposes errors and minimizes waste in the system, by using a "Pull System" using Kanban
    - Kanban - means "billboard" and it is a system to tell upstream processes to send work downstream
    - Kanban boards have at least three columns: To-Do, Doing, Done
    - Kanban boards limit work-in-progress (WIP) by limiting the number of items in the "Doing" column and only pulling in more work once the current work in progress is done
- Continuous Improvement with Key Performance Indicators (KPIs)

### TOC: The Theory of Constraints
- Throughput drives cost and revenue
- Throughput is constrained by one process in any system, the constraint
- To improve the System Throughput one must focus on optimizing around the Constraint
- To do this, use the 5 Focusing Steps for the Process of Ongoing Improvement (POOGI):
    - Identify the Constraint - figure out which process is limiting
    - Exploit the Constraint - try to optimize with existing capacity
    - Subordinate everything to the Constraint - reduce processes to match capacity of the constraint
    - Elevate the Constraint - add capacity to the constraint process
    - Prevent inertia from becoming the Constraint - be vigilant and check if there's a new constraint!

# Case Study
Netflix:
https://www.youtube.com/watch?v=wyWI3gLpB8o
- Culture of Innovation - ability to respond to opportunities as they presented themselves
- Data Analytics - this allows for comparing changes and determining if it works through real data (truth)
- Decentralized Decisions - the empowerment of employees to procure resources on-demand as needed
- Agile and Self-Service Deployment - the ability for developers to deploy but also be responsible for their code

18F
https://www.youtube.com/watch?v=lNSmF7-xisU




#### The Waterfall Mistake

- Waterfall was never intended to be linear in its design
- Royce, who proposed waterfall as a simple starting point for modeling work, stated all projects should iterate
    - Typical waterfall design:
    - Requirements - product requirements as output
    - Design - architecture as output
    - Implementation - system is produced
    - Verification - testing is conducted to fix the system where needed
    - Maintenance - support for product in use
- The actual design had at least one iteration going back from verification to implementation to design


## 2. Methods

Triple Cost Constraint
Scope - controlling the work done
Schedule - controlling the calendar time for doing the work
Budget - controlling capital expenditures

Controlling Scope

Traditional
 - Work Breakdown Structure (WBS) - controls work by concretely defining its components/ Often has three levels: Product, Major Features, Feature Components Used to define what will and will not be in a project
 - Change Control Board (CCB) - controls changes to the WBS by committee review 
  Includes all major stakeholders
  Must be organized and often slows changes to a project
Lean
- Tickets - identify work items and their priority for response (urgency and impact)
- Requests -  these are informal or semi-formal requests that could be tickets
Notes
Both tickets and requests go into a queue for work, and are executed through a value stream
Value streams are steps to complete work (e.g. define, analyze, build, test).
Agile
- Product Backlogs - the list of work to be done for the entire project. It's an ordered list of work increments.
- Sprint Backlog - the work that will get done during the sprint.

# Controzling Schedule
1. Traditional
Estimated Tasks and Schedules - work is estimated and modeled for precedence
Program Evaluation and Review Technique (PERT) - adds stochastic modeling of task completion
Critical Path Method (CPM) - uses deterministic modeling to identify critical tasks for on-time delivery

2. Lean
Kanban & Queues - work is managed in a list and executed based on priority
Service Agreements - sets the priority of work by defining what is critical, major, or minor

3. Agile
Timeboxes - a set period of time in which the most important work is done first
Releases and Roadmaps - sets goals for major features to be release together

# Controlling Budget
1. Earned Value Management (EVM) - compares current performance to the plan
2. Planned Value (PV) - shows the cost over time expected to complete the work on schedule
Earned Value (EV) - shows how much work is completed to date
3. Actual Cost (AC) - shows the cost so far to complete the work
Cost Centers
Evaluates the differences in performance by cost center
Cost Performance Index (CPI) is the factor EV / AC, where above 1.0 means good performance
Schedule Performance Index (SPI) is the factor (EV / PV), where above 1.0 means good performance
This allows you to estimate the costs or savings expected for on-time delivery of total scope

## Lean
Service and Severity Levels - sets the level at which the company reaps benefits from the solutions
Key Performance Indicators (KPIs) - evaluate performance against goals for set time periods

## Agile
Return on Investment (ROI)
Burndown Charts

# The key document that sets up the team is the Charter. This includes:

1. Project Objectives - what the sponsors and/or customers expect from this project
2. Stakeholders - who "has a stake" from sponsors to customers and why. Includes technical, security, business, and operational stakeholders
3. Constraints - what must the project also do or do not in accomplishing the objective, such as standards, interfaces, and dependencies
4. Risks - what are major risks (internal and external), this includes business, technical, political, social, environmental
5. Definition of Done - the agreement among stakeholders of how work is closed by the Product Owner and supporting stakeholders

## Once the Team Charter is in-place, the team should assemble based on the skills needed to do the work:

1. Product Owner - person responsible for managing the Product Backlog; can only be one person; 
2. Scrum Master - person responsible for facilitating and keeping the team on track; leads Sprint Planning and Retrospectives
3. Development Team Member - person on the team who takes responsibility for the team's success in completing the Sprint objectives
These are the general types of team members on a Scrum Team, however, we know that many times we need variations based on our organization. The following are typical variations

# Product Owners variations

Types
Business Representative - from the business line using the product, or subject matter expert (SME) for customer
Technical Expert - from the systems engineering or technology group of the customer, has experience with building for business lines
Sponsor - the executive, director, or product manager for a business line (internal or external); focuses on marketing and feature analysis
Business Owner - the owner of the business selling the product; often a combination of other types of representatives
Level of Availability
Dedicated - always on the team and available to the team; focusing on the backlog refinement whenever not supporting other team members
On-Call - available when needed at all times; however, may have limited time outside of team support for backlog refinement (e.g. other duties)
Matrixed - works on multiple products or projects, balancing time based on their own direction or the direction of departmental goals
Minimal - available only for Sprint ceremonies and minimal other times
Absent - available with long lead times for set consultation hours; cannot predict if/when they will be avialable
Scrum Master variations

# Types of facilitation
- Facilitator - facilitates planning meetings, daily scrums, coordination with stakeholders (requirements, etc.), and retrospectives
- Project Manager - works as facilitator, as well as managing human resources; and is responsible for reporting and project success 
- Junior Project Manager - works as facilitator and is responsible for reporting and project success for the Scrum team
- Business Analyst - works as facilitator and also provides supports for Product Owner and Development Team with requirements elaboration
## Types of Availability
- Dedicated - soles works on the Scrum team
- Split - works across multiple Scrum teams (can be the same or different projects or product lines)
- Rotating Team Member - can be a rotating member of the Development Team who acts as the Scrum Master for a Sprint
- Matrixed - can be part of a department with responsibilities to the department, Program, Program Management Office, etc.
- Minimal / Absent - can be only available for running ceremonies and on-call for other facilitation
Development Team Member variations

# Types of representation
- Generalizing Specialist - a team member that can perform any role as needed, but is trained in a certain skill set (usually development)
- Developer (Hard/Software) - a technical team member who focuses primarily on building the product to specifications
- Business Analyst / Tester - an analyst who defines and checks the work being developed by the team meets the Product Owner's intent
- Technical Writer - an analyst who provides support for other team members in capturing notes, metadata, and communicating work
- Architect - an experienced team member in a technical or business domains that serves as subject matter expert (SME)
- Support Team - a team member that provides enabling technology, such as work tracking software, builds, deployments, machining, etc.
## Types of Availability
- Dedicated - soles works on the Scrum team
- Split - works across multiple Scrum teams (can be the same or different projects or product lines)
- Matrixed - can be part of a department with responsibilities to the department, other projects or product lines, or Centers of Excellence
- On-Call - is available as needed, when needed by the team to provide surge support or expert guidance
- Absent - available with long lead times for set consultation hours; cannot predict if/when they will be available


# There are three parts to a User Story:

Value Statement
As a...[Who]...I want to...[What Functionality Desired]...in order to...[Why It's Important].

Assumptions
Acceptance Criteria


## Sprint Planning has three key objectives:

- Product Owner presents the updated Product Backlog
- Development Team selects and refines User Stories
- Development Team is able to commit to the Sprint Backlog
However, to ensure the authenticity of those objectives are met the following must happen:

## All voices must be heard
Team must review and elaborate all User Stories in the Sprint
The Team must be able to size and select those stores within the timebox of the Sprint Planning!

## The key to making a good Sprint Planning Work is two-fold:
Great User Story writing by the Product Owner (and/or Development Team in variations of Scrum)
Planning Games

# Sprint Development Summary Points
1. Daily Stand Ups - daily face to face communication so there's no "scheduling" of coordination
2. Whole Teams - Everyone knows what the work is (we planned it together), and works on it together
3. Team Ownership - Multiple team members working on the same User Story
4. Limit WIP - limit the Work-In-Progress (WIP) to achieve faster, predictable development with focused time

# Two parts to the end of a Sprint:
1. Sprint Review: the Product Owner presents the completed, potentially shippable increment to the stakeholders.\
Goals of a Sprint Review:
- Validate the product is something the users want
- Discuss what the next features should be
- Build stakeholder buy-in
- Force a shippable product to be ready*

2. Sprint Retro: the Sprint Team collaboratively inspects the sprint and looks for ways to build on or change for the better.

# SAFe:
New roles:
- System Teams - those that manage delivery and integration of products produced by individual Scrum teams
- Architecture Teams - manages and promotes the shared architecture framework across teams
- Product Manager - leads the Product Owners as the primary person in charge of targeting features and EPICs
- Release Train Engineer - leads the Scrum Masters on each of the Scrum teams, and conducts the large team or team ceremonies

## "Agile Release Train" or ART.
- Agile Release Trains (ARTs) align to one or more similar parts of the Business Value Stream
- ARTs are limited to up to 120 people, keeping on the lowside of Dunbar's number
- ARTs work together through the Sprint process, with shared ceremonies at the Release boundaries

Program Increments (PI) Planning
Program Increment Inspect and Adapt (IA)

## A couple of the principles that make SAFe work are:

- Take an economic view - Instead of just responding to customer wishes, work is evaluated in terms of cost of delay (CoD).
- Plan on cadence, release on demand - All teams must plan together, but they can release whenever work is ready.
- Base milestones on objective evaluation of working systems - The work is only considered done when it is fully demoed at the system level
- Visualize and limit WIP, reduce batch sizes, and manage queue lengths - leverage the Lean principles of limiting WIP and managing queues with small batches helps prevent turning independent teams back into departmental-like groups

## SAFe has three four levels of implementation to help answer these ideas:

1. Essential SAFe - basic SAFe with only Business Owners managing as executives often on a single Agile release train (ART)
2. Portfolio SAFe - includes a portfolio management function to align funding across teams or trains
3. Large-Solution SAFe - Introduces the concepts of having Suppliers that integrate delivery along with multiple ARTs on a Solution Train
4. Full SAFe - Includes a Portfolio Management function above the Large-Solution when managing across Solution Trains and other ARTs

# DAD - Disciplined Agile Delivery
##The key characteristics of Disciplined Agile Delivery are:

People first
Learning oriented
Agile
Hybrid
Goal-driven 
Delivery focused
Enterprise aware
Risk and value driven
Scalable

## DAD uses a startup phase called "Inception." During this phase many important things happen to help scale:

1. Modeling of the solution
2. Proof of concepts are explored
3. Shared architectures across teams are initiated
4. High-level release planning and feature roadmaps are established

## Support teams include everything that could be considered "Development-Operations" or DevOps:

- IT Operations
- Customer Support
- Security
- Data Management
- Release Management


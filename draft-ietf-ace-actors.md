---
title: An architecture for authorization in constrained environments
abbrev: ace-actors
docname: draft-ietf-ace-actors-05
date: 2017-11-14
category: info

ipr: trust200902
area: Security
workgroup: ACE Working Group
keyword: Internet-Draft

stand_alone: yes
pi: [toc, sortrefs, symrefs, comments, inline]

author:
 -
    ins: S. Gerdes
    name: Stefanie Gerdes
    org: Universität Bremen TZI
    street: Postfach 330440
    city: Bremen
    code: D-28359
    country: Germany
    phone: +49-421-218-63906
    email: gerdes@tzi.org
 -
    ins: L. Seitz
    name: Ludwig Seitz
    org: RISE SICS
    street: Scheelevägen 17
    city: Lund
    code: 223 70
    country: Sweden
    email: ludwig.seitz@ri.se
 -
    ins: G. Selander
    name: Göran Selander
    org: Ericsson
    street: Farögatan 6
    city: Kista
    code: 164 80
    country: Sweden
    email: goran.selander@ericsson.com
 -
    ins: C. Bormann
    name: Carsten Bormann
    org: Universität Bremen TZI
    street: Postfach 330440
    city: Bremen
    code: D-28359
    country: Germany
    phone: +49-421-218-63921
    email: cabo@tzi.org
    role: editor

informative:
  RFC7230:
  RFC6347:
  RFC7252: coap
  RFC5246:
  RFC4120:
  RFC6749: oauth
  RFC4949:
  RFC2904:
  I-D.irtf-t2trg-iot-seccons: coresec
  RFC7744: usecases
  RFC7228:
  RFC7231:
  I-D.hardjono-oauth-umacore: uma
  I-D.ietf-core-object-security: objsec
  I-D.ietf-core-coap-pubsub: pubsub
  HUM14delegation:
    author:
      - ins: R. Hummen
      - ins: H. Shafagh
      - ins: S. Raza
      - ins: T. Voigt
      - ins: K. Wehrle
    title: >
      Delegation-based Authentication and Authorization for the
      IP-based Internet of Things
    seriesinfo:
      "11th IEEE International Conference on":
          "Sensing, Communication, and Networking (SECON'14)"
      "June 30 -": "July 3"
    date: 2014
  OSCAR:
    author:
    - ins: M. Vucinic
    - ins: B. Tourancheau
    - ins: F. Rousseau
    - ins: A. Duda
    - ins: L. Damon
    - ins: R. Guizzetti
    title: >
      OSCAR: Object Security Architecture for the Internet of Things
    seriesinfo:
      CoRR: vol. abs/1404.7799
    date: 2014
  REST:
    seriesinfo:
      ACM Trans. Inter. Tech.: Vol. 2(2), pp. 115-150
      DOI: 10.1145/514183.514185
    title: Principled design of the modern Web architecture
    author:
    - name: Roy T. Fielding
      ins: R. Fielding
    - name: Richard N. Taylor
      ins: R. Taylor
    date: '2002-05-01'

--- abstract

Constrained-node networks are networks where some nodes have severe
constraints on code size, state memory, processing capabilities, user
interface, power and communication bandwidth (RFC 7228).

This document provides terminology, and identifies the elements that
an architecture needs to address, providing
a problem statement, for authentication and authorization in these
networks.

--- middle


# Introduction

As described in {{RFC7228}}, constrained nodes are small devices with
limited abilities which in
many cases are made to fulfill a specific simple task. They may have limited
hardware resources such as processing power, memory, non-volatile storage and
transmission capacity and additionally in most cases do not have user
interfaces and displays. Due to these constraints, commonly used
security protocols are not always easily applicable, or may give rise
to particular deployment/management challenges.

As components of the Internet of Things (IoT),
constrained nodes are expected to be integrated in all aspects of
everyday life and thus will be entrusted with vast amounts of
data. Without appropriate security mechanisms attackers might gain
control over things relevant to our lives. Authentication and
authorization mechanisms are therefore
prerequisites for a secure Internet of Things.

Applications generally require some degree of authentication and
authorization, which gives rise to some complexity.
Authorization is about who can do what to which objects (see also {{RFC4949}}).
Authentication specifically addresses the who, but is often specific
to the authorization that is required (for example, it may be sufficient to
authenticate the age of an actor, so no identifier is needed or even
desired).
Authentication often involves credentials, only some of
which need to be long-lived and generic; others may be directed
towards specific authorizations (but still possibly long-lived).
Authorization then makes use of these credentials, as well as other
information (such as the time of day).
This means that the complexity of authenticated authorization can
often be moved back and forth between these two aspects.

In some cases authentication and authorization can be addressed by
static configuration provisioned during manufacturing or deployment by
means of fixed trust anchors and static access control lists.  This is
particularly applicable to siloed, fixed-purpose deployments.

However, as the need for flexible access to assets already deployed
increases, the legitimate set of authorized entities as well as their specific
privileges cannot be conclusively defined during deployment, without
any need for change during the lifetime of the device. Moreover,
several use cases illustrate the need for fine-grained access control
policies, for which for instance a basic access control list concept
may not be sufficiently powerful {{-usecases}}.

The limitations of the constrained nodes impose a need for security mechanisms
which take the special characteristics of constrained environments
into account; not all constituents may be able to perform all
necessary tasks by themselves.  To put it the other way round: the
security mechanisms that protect constrained nodes must remain
effective and manageable despite the limitations imposed by the
constrained environment.

Therefore, in order to be able to achieve complex security objectives between
actors some of which are hosted on simple ("constrained") devices,
some of the actors will make use of help from other, less constrained
actors.  (This offloading is not specific to networks with constrained
nodes, but their constrainedness as the main motivation is.)

We therefore group the logical functional entities by whether
they can be assigned to a constrained device ("constrained level") or
need higher function platforms ("less-constrained level"); the latter
does not necessarily mean high-function, "server" or "cloud"
platforms.  Note that assigning a logical functional entity to the
constrained level does not mean that the specific implementation needs
to be constrained, only that it *can* be.

The description assumes that some form of setup (aspects of which are
often called provisioning and/or commissioning) has already been
performed and at least some initial security relationships important
for making the system operational have already been established.

This document provides some terminology, and identifies the elements an
architecture needs to address, representing the relationships between
the logical
functional entities involved; on this basis, a problem description for
authentication and authorization in constrained-node networks is
provided.

## Terminology

Readers are assumed to be familiar with the terms and concepts
defined in {{RFC4949}}, including "authentication", "authorization",
"confidentiality", "(data) integrity", "message authentication code",
and "verify".

REST terms including "resource", "representation", etc. are to be
understood as used in HTTP {{RFC7231}} and CoAP {{RFC7252}}; the
latter also defines additional terms such as "endpoint".

Terminology for constrained environments including "constrained
device", "constrained-node network", "class 1", etc. is defined in
{{RFC7228}}.

In addition, this document uses the following terminology:

Resource (R):
: an item of interest which is represented through an interface.
  It might contain sensor or actuator values or other information.
  (Intended to coincide with the definitions of {{RFC7252}} and
  {{RFC7231}}.)

Constrained node:
: a constrained device in the sense of {{RFC7228}}.

Actor:
: A logical functional entity that performs one or more
  tasks. Multiple actors may be present within a single device or a
  single piece of software.

Resource Server (RS):
: An entity which hosts and represents a Resource.
  (Used here to discuss the server that provides a resource that is
  the end, not the means, of the authenticated authorization process
  -- i.e., not CAS or AS.)

Client (C):
: An entity which attempts to access a resource on a RS.
  (Used to discuss the client whose access to a resource is the end,
  not the means, of the authenticated authorization process.)

Principal:
: (Used in its English sense here, and specifically as:)
  An individual that is either RqP or RO or both.

Resource Owner (RO):
: The principal that is in charge of the resource and controls its access permissions.

Requesting Party (RqP):
: The principal that is in charge of the Client and controls the
  requests a Client makes and its acceptance of responses.

Authorization Server (AS):
: An entity that prepares and endorses authentication and
authorization data for a Resource Server.

Client Authorization Server (CAS):
: An entity that prepares and endorses authentication and
authorization data for a Client.

Authorization Manager:
: An entity that prepares and endorses authentication and
  authorization data for a constrained node.  Used in constructions
  such as "a constrained node's authorization manager" to denote AS
  for RS and CAS for C.

Authenticated Authorization:
: The confluence of mechanisms for authentication and authorization,
  ensuring that authorization is applied to and made available for
  authenticated entities and that entities providing authentication
  services are authorized to do so for the specific authorization
  process at hand.

Note that other authorization architectures such as OAuth {{-oauth}}
or UMA {{-uma}} focus on the authorization problems on the RS side, in
particular what accesses to resources the RS is to allow.  In this
document the term authorization includes this aspect, but is also used
for the client-side aspect of authorization, i.e., more generally
allowing RqPs to decide what interactions clients
may perform with other endpoints.

# Architecture and High-level Problem Statement {#ps}

This document deals with how to control and protect resource-based
interaction between potentially constrained endpoints. The following
setting is assumed as a high-level problem statement:

*  An endpoint may host functionality of one or more actors.

*  C in one endpoint requests to access R on a RS in another endpoint.

*  A priori, the endpoints do not necessarily have a pre-existing
   security relationship to each other.

*  Either of the endpoints, or both, may be constrained.

## Elements of an Architecture

In its simplest expression, the architecture starts with a two-layer model:
the principal level (at which components are assumed to be
functionally unconstrained) and the constrained level (at which some
functional constraints are assumed to apply to the components).

Without loss of generality, we focus on the C functionality in one
endpoint, which we therefore also call C, accessing the RS
functionality in another endpoint, which we therefore also call RS.

The constrained level and its security objectives are detailed in
{{cla}}.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        --------------                          --------------
        |  -------   |                          |  -------   |
        |  |  C  | ------ requests resource -----> | RS  |   |
        |  ------- <----- provides resource ------ -------   |
        |  Endpoint  |                          |  Endpoint  |
        --------------                          --------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{: #figbasic title="Constrained Level"}

<!-- graphic: request.png -->

The authorization decisions at the endpoints are made on behalf of the
principals that control the endpoints.  To reuse OAuth and UMA
terminology, the present document calls the principal that is controlling C the Requesting Party
(RqP), and calls the principal that is controlling RS the Resource Owner
(RO).  Each principal makes authorization decisions (possibly encapsulating them
into security policies) which are then enforced by the endpoint it controls.

The specific security objectives will vary, but for any specific
version of this scenario will include one or more of:

* Objectives of type 1: No entity not authorized by the RO has access to (or otherwise
  gains knowledge of) R.
* Objectives of type 2: C is exchanging information with (sending a
  request to, accepting a response from) a resource only where it can
  ascertain that RqP has authorized the exchange with R.

Objectives of type 1 require performing authorization on the Resource Server side while
objectives of type 2 require performing authorization on the Client side.

More on the security objectives of the principal level in {{pl}}.

      -------                           -------
      | RqP |                           |  RO | Principal Level
      -------                           -------
         |                                 |
    in charge of                      in charge of
         |                                 |
         V                                 V
      -------                           -------
      |  C  |  -- requests resource --> | RS  | Constrained Level
      -------  <-- provides resource--  -------
{: #figclandpl title="Constrained Level and Principal Level"}

The use cases defined in {{-usecases}} demonstrate that
constrained devices are often used for scenarios where their
principals are not present at the time of the communication,
are not able to communicate directly with the device because of a lack
of user interfaces or displays, or may prefer the device to
communicate autonomously.

<!--
The devices therefore need to be able to communicate
autonomously. In some scenarios there is an active user at one
endpoint of the communication. Other scenarios ask for true machine to
machine (M2M) communication.

To achieve the principals' security objectives, the devices must be
enabled to enforce the security decisions and policies of their
principals.
 -->

Moreover, constrained endpoints may need support with tasks requiring heavy
processing, large memory or storage, or interfacing to humans, such as
management of security policies defined by a principal. The principal,
in turn, requires some agent maintaining the policies governing how
its endpoints will interact.

For these reasons, another level of nodes is introduced in the
architecture, the less-constrained level (illustrated below in {{figalllevels}}).
Using OAuth terminology, AS
acts on behalf of the RO to control and support the RS in handling
access requests, employing a pre-existing security relationship with
RS.  We complement this with CAS acting on behalf of RqP to control
and support the C in making resource requests and acting on the
responses received, employing a pre-existing security relationship
with C.  To further relieve the constrained level, authorization (and
related authentication) mechanisms may be employed between CAS and AS
({{lclp}}).
(Again, both CAS and AS are conceptual entities controlled by their
respective principals.  Many of these entities, often acting for
different principals, can be combined into a single server
implementation; this of course requires proper segregation of the
control information provided by each principal.)

     -------                           -------
     | RqP |                           |  RO | Principal Level
     -------                           -------
        |                                 |
    controls                          controls
        |                                 |
        V                                 V
    --------                          -------
    |  CAS |  <- AuthN and AuthZ ->   |  AS |  Less-Constrained Level
    --------                          -------
        |                                 |
    controls and supports        controls and supports
    authentication               authentication
    and authorization            and authorization
        |                                 |
        V                                 V
     -------                           -------
     |  C  |  -- requests resource --> | RS  | Constrained Level
     -------  <-- provides resource--  -------
{: #figalllevels title="Overall architecture"}

{{figalllevels}} shows all three levels considered in this document.
Note that the vertical arrows point down to illustrate exerting
control and providing support; this is complemented by information
flows that often are bidirectional.
Note also that not all entities need to be ready to communicate at any
point in time; for instance, RqP may have provided enough information
to CAS that CAS can autonomously negotiate access to RS with AS for C
based on this information.

## Architecture Variants

The elements of the architecture described above are indeed
architectural; that is, they are parts of a conceptual model, and
may be instantiated in various ways in practice.
For example, in a given scenario, several elements might share a single device or
even be combined in a single piece of software. If C is located on a
more powerful device, it can be combined with CAS:

<!-- Graphic: combined-c-cas -->

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   -------                          --------
   | RqP |                          |  RO  |   Principal Level
   -------                          --------
     |                                  |
in charge of                       in charge of
     |                                  |
     V                                  V
------------                        --------
|  CAS + C | <- AuthN and AuthZ ->  |  AS  |  Less-Constrained Level
------------                        --------
            ^                            |
             \__                         |
                \___                 authentication
                    \___             and authorization
     requests resource/ \___          support
     provides resource      \___        |
                                \___    |
                                    V   V
                                     -------
                                     | RS  | Constrained Level
                                     -------

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{: #figcombined-c-cas title="Combined C and CAS"}

If RS is located on a more powerful device, it can be combined with AS:

<!-- Graphic: combined-rs-as -->

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   -------                            -------
   | RqP |                            |  RO |   Principal Level
   -------                            -------
     |                                  |
in charge of                       in charge of
     |                                  |
     V                                  V
----------                        -----------
|  CAS   | <- AuthN and AuthZ ->  | RS + AS |  Less-Constrained Level
----------                        -----------
     |                           ^
authentication               ___/
and authorization        ___/
support              ___/ request resource / provides resource
     |           ___/
     V       ___/
  -------   /
  |  C  | <-
  -------

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{: #figcombined-rs-as title="Combined AS and RS"}



<!-- Graphic: combined-cas-as -->


If C and RS have the same principal, CAS and AS can be combined.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                ------------
                | RqP = RO |   Principal Level
                ------------
                      |
                  in charge of
                      |
                      V
              --------------
              |  CAS + AS  |  Less-Constrained Level
              --------------
             /                \
            /                  \
authentication               authentication
and authorization            and authorization
support                      support
         /                        \
        V                          V
  -------                          -------
  |  C  | -- requests resource --> | RS  | Constrained Level
  ------- <-- provides resource -- -------

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{: #figcombined-cas-as title="CAS combined with AS"}


## Information Flows {#iflo}

We now formulate the problem statement in terms of the information
flows the architecture focuses on.  (While the previous section
discusses the architecture in terms of abstract devices and their
varying roles, the actual protocols being standardized define those
information flows and the messages embodying them: "RESTful
architectures focus on defining interfaces and not components" ({{REST}},
p. 116).)

The interaction with the nodes on the principal level, RO and RqP, is
not involving constrained nodes and therefore can employ an existing mechanism.
The less-constrained nodes, CAS and AS, support the constrained nodes, C and RS,
with control information, for example permissions of clients,
conditions on resources, attributes of client and resource servers,
keys and credentials.  This control information may be rather different
for C and RS.

The potential information flows are shown in
{{figflows}}. The direction of
the vertical arrows expresses the
exertion of control; actual information flow is bidirectional.

The message flow may pass unprotected paths and thus need to be
protected, potentially beyond a single REST hop ({{e2e}}):

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -------                                     -------
  | CAS |                                     | AS  |
  -------                                     -------
  a ^ | b   a = requests for control info     a ^ | b
    | |     b = control information             | |
    | v                                         | v
  -------                                     -------
  | C   | ------ request -------------------> | RS  |
  |     | <----- response ------------------- |     |
  -------                                     -------

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{: #figflows title="Information flows that need to be protected"}

* We assume that the necessary keys/credentials for protecting the
  control information between the potentially constrained nodes and
  their associated less-constrained nodes are pre-established, for
  example as part of the commissioning procedure.

* Any necessary keys/credentials for protecting the interaction between
  the potentially constrained nodes will need to be established and
  maintained as part of a solution.

In terms of the elements of the architecture laid out above,
this document's problem statement for authorization in
constrained environments can then be summarized as follows:

* The interaction between potentially constrained endpoints is
  controlled by control information provided by less-constrained nodes
  on behalf of the principals of the endpoints.

* The interaction between the endpoints needs to be secured, as well
  as the establishment of the necessary keys for securing the
  interaction, potentially end-to-end through intermediary nodes.

* The mechanism for transferring control information needs to be
  secured, potentially end-to-end through intermediary nodes.
  Pre-established keying material may need to be employed for
  establishing the keys used to protect these information flows.

(Note that other aspects relevant to secure constrained node
communication such as secure bootstrap or group communication are not
specifically addressed by the present document.)

# Security Objectives {#security_objectives}

The security objectives that are
addressed by an authorization solution include confidentiality and
integrity. Additionally, an authorization solution has an impact on the
availability: First, by reducing the load (only accepting selected operations by
selected entities limits the burden on system resources), and second,
because misconfigured or wrongly designed authorization solutions can
result in availability breaches (denial of service) as users might no
longer be able to use data and services as they are supposed to.

Authentication mechanisms can help achieve additional security objectives
such as accountability and third-party verifiability. These additional
objectives are not directly related to authorization and thus are not in scope
of this draft, but may nevertheless be relevant.
Accountability and third-party verifiability may require authentication on a
device level, if it is necessary to determine which device performed an
action. In other cases it may be more important to find out who is
responsible for the device's actions.
(The ensuing requirements for logging, auditability, and the related
integrity requirements are very relevant for constrained devices as
well, but outside the scope of this document.)
See also {{ana}} for more discussion about authentication and authorization.

The security objectives and their relative importance differ for the
various constrained environment applications and use cases
{{-usecases}}.

The architecture is based on the observation that different parties
may have different security objectives.
There may also be a "collaborative" dimension: to achieve a security
objective of one party, another party may be required to provide a
service.
For example, if RqP requires the integrity of representations of a
resource R that RS is hosting, both C and RS need to partake in
integrity-protecting the transmitted data.
Moreover, RS needs to protect any write access to this resource as
well as to relevant other resources (such as configuration
information, firmware update resources) to prevent unauthorized users
from manipulating R.

## End-to-End Security Objectives in Multi-Hop Scenarios {#e2e}

In many cases, the information flows described in {{iflo}} cross
multiple client-server pairings but still
need to be protected end-to-end.  For example, AS may not be connected
to RS (or may not want to exercise such a connection), relying on C
for transferring authorization information. As the authorization
information is related to the permissions granted to C, C must not be
in a position to manipulate this information, which therefore requires
integrity protection on the way between AS and RS.

As another example, resource representations sent between endpoints
may be stored in intermediary nodes, such as caching proxies or
pub-sub brokers.  Where these intermediaries cannot be relied on to
fulfill the security objectives of the endpoints, it is the endpoints
that will need to protect the exchanges beyond a single client-server
exchange.

Note that there may also be cases of intermediary nodes that very much
partake in the security objectives to be achieved.  The question what
are the pairs of
endpoints between which the communication needs end-to-end protection (and which
aspect of protection) is defined
by the specific use case. Two examples of intermediary nodes executing security functionality:

* To enable a trustworthy publication service, a pub-sub broker may be untrusted
with the plaintext content of a publication (confidentiality),
but required to verify that the publication is
performed by claimed publisher and is not a replay of an old
publication (authenticity/integrity).
* To comply with requirements of transparency, a gateway may be allowed to read,
verify (authenticity) but not modify (integrity) a resource representation
which therefore also is end-to-end integrity protected from the server
towards a client behind the gateway.

In order to support the required communication and application
security, keying material needs to be established between the relevant
nodes in the architecture.

# Authentication and Authorization {#ana}

Server-side authorization solutions aim at protecting the access to
items of interest, for instance hardware or software resources or data: They
enable the resource owner to control who can access it
and how.

To determine if an entity is authorized to access a resource, an
authentication mechanism is needed. According to the Internet
Security Glossary {{RFC4949}}, authentication is "the process of
verifying a claim that a system entity or system resource has a
certain attribute value." Examples for attribute values are the ID of
a device, the type of the device or the name of its owner.

The security objectives the authorization mechanism aims at can only
be achieved if the authentication and the authorization mechanism work
together correctly. We speak of authenticated authorization to refer
to the required synthesis of mechanisms for authentication and
authorization.

Where used for authorization, the set of authenticated attributes must
be meaningful for this purpose, i.e., authorization decisions must be
possible based on these attributes. If the authorization policy
assigns permissions to an individual entity, the set of authenticated
attributes must be suitable to uniquely identify this entity.

In scenarios where devices are communicating autonomously there is
often less need to uniquely identify an individual device: For a
principal, the fact that a device belongs to a certain company or that
it has a specific type (such as a light bulb) or location may be more
important than that it has a unique identifier.

(As a special case for the authorization of read access to a resource,
RS may allow everyone to access an encrypted representation of the resource
{{OSCAR}}.  In this case, controlling read access to that resource can
be reduced to controlling read access to the key; partially removing
future access requires that the resource representation is re-encrypted
and the new key is made available to all participants that are 
still authorized.)

Principals (RqP and RO) need to decide about the required level of
granularity for the authorization.  For example, we distinguish device
authorization from owner authorization, and flat
authorization from unrestricted authorization. In the first case
different access permissions are
granted to individual devices while in the second case individual
owners are authorized. If flat authorization is used, all
authenticated entities are implicitly authorized and have the same access permissions.
Unrestricted authorization for an item of interest means that no
authorization mechanism is used for accessing this resource (not even
by authentication) and all entities are able to access the item as
they see fit (note that an authorization mechanism may still be used
to arrive at the decision to employ unrestricted authorization).

| Authorization granularity | Authorization is contingent on:                 |
| device                    | authentication of specific device               |
| owner                     | (authenticated) authorization by owner          |
| flat                      | (any) authentication                            |
| unrestricted              | (unrestricted access; access always authorized) |
{: #fig-grain title="Some granularity levels for authorization" cols="20%l l"}

More fine-grained authorization does not necessarily provide more
security but can be more flexible. Principals need to consider that an
entity should only be granted the permissions it really needs
(principle of least privilege), to ensure the confidentiality and
integrity of resources.


Client-side authorization solutions aim at protecting the client from
disclosing information to or ingesting information from resource
servers RqP does not want it to interact with in the given way.
Again, flat authorization (the server can be authenticated) may be
sufficient, or more fine-grained authorization may be required.
The client-side authorization also pertains to the level of protection
required for the exchanges with the server (e.g., confidentiality).
In the browser web, client-side authorization is often left to the
human user; a constrained client may not have that available all the
time but still needs to implement the wishes of the principal
controlling it, the RqP.

For the cases where an authorization solution is needed (all but
unrestricted authorization), the enforcing party needs to be able to
authenticate the party that is to be authorized.  Authentication is
therefore required for messages that contain (or otherwise update)
representations of an accessed item. More precisely: The enforcing
party needs to make sure that the receiver of a message containing a
representation is authorized to receive it, both in the case of a
client sending a representation to a server and vice versa. In
addition, it needs to ensure that the actual sender of a message
containing a representation is indeed the one authorized to send this
message, again for both the client-to-server and server-to-client
case. To achieve this, integrity protection of these messages is
required: Authenticity of the message cannot be assured if it is
possible for an attacker to modify it during transmission.

In some cases, only one side (client or server
side) requires the integrity and / or confidentiality of a resource
value.  Principals may decide to omit authentication (unrestricted
authorization), or use flat authorization (just employing an
authentication mechanism).
However, as indicated in {{security_objectives}}, the
security objectives of both sides must be considered, which can often
only be achieved when the other side can be relied on to perform
some security service.

<!-- Validate that an entity has certain attributes which entitle it to
access a resource. -->


# Actors and their Tasks {#actors}

This and the following section look at the resulting architecture from
two different perspectives:
This section provides a more detailed description of the various
"actors" in the architecture, the logical functional entities
performing the tasks required.
The following section then will focus on the protocols run between
these functional entities.

For the purposes of this document, an actor consists of a set of tasks
and additionally has a security domain (client domain or server
domain) and a level (constrained, principal, less-constrained). Tasks
are assigned to actors according to their security domain and required
level.

Note that actors are a concept to understand the security requirements
for constrained devices. The architecture of an actual solution might
differ as long as the security requirements that derive from the
relationship between the identified actors are considered. Several
actors might share a single device or even be combined in a single
piece of software.  Interfaces between actors may be realized as
protocols or be internal to such a piece of software.

A more detailed discussion of the tasks the actors have to perform in
order to achieve specific security objectives is provided in {{?I-D.gerdes-ace-tasks}}.

## Constrained Level Actors {#cla}

As described in the problem statement (see {{ps}}), either C or RS or both of
them may be located on a constrained node. We therefore define that C
and RS must be able to perform their tasks even if they are located on
a constrained node. Thus, C and RS are considered to be Constrained
Level Actors.

C performs the following tasks:

 * Communicate in a secure way (provide for confidentiality and
   integrity of messages), including access requests.
 * Validate that the RqP ("client-side") authorization information
   allows C to communicate with RS as a server for R (i.e., from C's
   point of view, RS is authorized as a server for the specific access
   to R).

RS performs the following tasks:

 * Communicate in a secure way (provide for confidentiality and
   integrity of messages), including responses to access requests.
 * Validate that the RO ("server-side") authorization information
   allows RS to grant C access to the requested
   resource as requested (i.e., from RS' point of view, C is
   authorized as a client for the specific access to R).

R is an item of interest such as a sensor or actuator value. R is
considered to be part of RS and not a separate actor. The device
on which RS is located might
contain several resources controlled by different ROs.  For
simplicity of exposition, these resources are described as if they had
separate RS.

As C and RS do not necessarily know each other they might belong to
different security domains.

(See {{figcl}}.)

<!-- Graphic: constrained_level_small.png -->

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        -------                            --------
        |  C  |  -- requests resource ---> |  RS  | Constrained Level
        -------  <-- provides resource---  --------

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{: #figcl title="Constrained Level Actors"}

## Principal Level Actors {#pl}

Our objective is that C and RS are under control of principals in the physical world, the Requesting Party (RqP)
and the Resource Owner (RO) respectively.  The principals decide about the
security policies of their respective endpoints; each principal belongs to the same
security domain as their endpoints.

RqP is in charge of C, i.e. RqP specifies security policies for C,
such as with whom C is allowed to communicate. By definition, C and RqP
belong to the same security domain.

RqP must fulfill the following task:

* Configure for C authorization information for sources for R.

RO is in charge of R and RS. RO specifies authorization policies for R
and decides with whom RS is allowed to communicate. By definition, R, RS and RO
belong to the same security domain.

RO must fulfill the following task:

* Configure for RS authorization information for accessing R.

(See {{figclandpl}}.)

<!-- Graphic security_domains_owners.png -->


## Less-Constrained Level Actors {#lcl}

Constrained level actors
can only fulfill a limited number of tasks and may not have network
connectivity all the time. To relieve them from
having to manage keys for numerous endpoints and conducting
computationally intensive tasks, another level of complexity for actors is
introduced (and, thus, a stricter limit on their constrainedness).  An actor on the less-constrained level belongs to the
same security domain as its respective constrained level actor. They
also have the same principal.

The Client Authorization Server (CAS) belongs to the same security domain as
C and RqP. CAS acts on behalf of RqP. It assists C in authenticating RS
and determining if RS is an authorized server for R. CAS can do that
because for C, CAS is the authority for claims about RS.

CAS performs the following tasks:

 * Validate on the client side that an entity has certain attributes.
 * Obtain authorization information about an entity from C's principal (RqP) and
   provide it to C.
 * Negotiate means for secure communication to communicate with C.

The Authorization Server (AS) belongs to the same security domain as
R, RS and RO. AS acts on behalf of RO. It supports RS by
authenticating C and determining C's permissions on R. AS can do that
because for RS, AS is the authority for claims about C.

AS performs the following tasks:

 * Validate on the server side that an entity has certain attributes.
 * Obtain authorization information about an entity from RS' principal (RO) and
   provide it to RS.
 * Negotiate means for secure communication to communicate with RS.


<!-- Graphic: eierlegendewollmilchsau2.png -->

<!-- (See {{figalllevels}}; for more detailed graphics please consult the -->
<!-- PDF version.) -->

# Kinds of Protocols

Devices on the less-constrained level potentially are more powerful than
constrained level devices in terms of processing power, memory,
non-volatile storage. This results in different characteristics for the
protocols used on these levels.

## Constrained Level Protocols

A protocol is considered to be on the constrained level if it is used
between the actors C and RS which are considered to be constrained
(see {{cla}}). C and RS might not belong to the same security
domain. Therefore, constrained level protocols need to work
between different security domains.

<!-- graphic: tasks_cl.png -->

Commonly used Internet protocols can not in every case be applied to
constrained environments. In some cases, tweaking and profiling is
required. In other cases it is beneficial to define new protocols
which were designed with the special characteristics of constrained
environments in mind.

On the constrained level, protocols need to address the specific
requirements of constrained environments. Examples for protocols that
consider these requirements is the transfer protocol CoAP (Constrained
Application Protocol) {{RFC7252}} and the Datagram Transport Layer
Security Protocol (DTLS) {{RFC6347}} which can be used for channel
security.

Constrained devices have only limited storage space and thus cannot
store large numbers of keys. This is especially important because
constrained networks are expected to consist of thousands of
nodes. Protocols on the constrained level should keep this limitation
in mind.

### Cross Level Support Protocols

We refer to protocols that operate between a constrained device and
its corresponding less-constrained device as cross-level support
protocols. Protocols used between C and CAS
or RS and AS are therefore support protocols.

Support protocols must consider the limitations of their constrained
endpoint and therefore belong to the constrained level protocols.

## Less-Constrained Level Protocols {#lclp}

A protocol is considered to be on the less-constrained level if it is
used between the actors CAS and AS. CAS and AS might belong to
different security domains.

On the less-constrained level, HTTP {{RFC7230}} and Transport Layer
Security (TLS) {{RFC5246}} can be used alongside or instead of CoAP and
DTLS. Moreover, existing security solutions for authentication and
authorization such as the OAuth web authorization framework
{{RFC6749}} and Kerberos {{RFC4120}} can likely be used without
modifications and the less-constrained layer is
assumed to impose no constraints that would inhibit the traditional
deployment/use of, e.g., a Public Key Infrastructure (PKI).

<!-- graphic: tasks_lcl.png -->

# Elements of a Solution

Without anticipating specific solutions, the following considerations
may be helpful in discussing them.

## Authorization {#probaz}

   The core problem we are trying to solve is authorization.  The
   following problems related to authorization need to be addressed:

* AS needs to transfer authorization information to RS and CAS needs
  to transfer authorization information to C.

*  The transferred authorization information needs to follow a
        defined format and encoding, which must be efficient for
        constrained devices, considering size of authorization
        information and parser complexity.

* C and RS need to be able to verify the authenticity of the
        authorization information they receive.  Here as well, there
        is a trade-off between processing complexity and deployment
        complexity.

* The RS needs to enforce the authorization decisions of the AS, while
  C needs to abide with the authorization decisions of the CAS. The
  authorization information might require additional policy evaluation
  (such as matching against local access control lists, evaluating local
  conditions). The required "policy evaluation" at the constrained
  actors needs to be adapted to the capabilities of the devices
  implementing them.


*  Finally, as is indicated in the previous bullet, for a
        particular authorization decision there may be different kinds
        of authorization information needed, and these pieces of
        information may be transferred to C and RS at different times and in
        different ways prior to or during the client request.


## Authentication

   The following problems need to be addressed, when considering
   authentication:

* RS needs to authenticate AS, and C needs to authenticate CAS, to
        ensure that the authorization information and related data
        comes from the correct source.

* CAS and AS may need to authenticate each other, both to perform
  the required business logic and to ensure that CAS gets security
  information related to the resources from the right source.

*  In some use cases RS needs to authenticate some property of C,
        in order to map it to the relevant authorization information.
        In other applications, authentication and authorization of C may be
        implicit, for example by encrypting the resource representation the RS
        only providing access to those who possess the key to decrypt.

*  C may need to authenticate RS, in order to ensure that it is
        interacting with the right resources.   Alternatively C may just
        verify the integrity of a received resource representation.

*  CAS and AS need to authenticate their communication partner (C
        or RS), in order to ensure it serves the correct device.


## Communication Security

   There are different alternatives to provide communication security,
   and the problem here is to choose the optimal one for each scenario.
   We list the available alternatives:

*  Session-based security at transport layer such as DTLS {{RFC6347}}
        offers security, including integrity and confidentiality
        protection, for the whole application layer exchange.  However,
        DTLS may not provide end-to-end security over multiple hops.
        Another problem with DTLS is the cost of the handshake protocol,
        which may be too expensive for constrained devices especially in
        terms of memory and power consumption for message transmissions.

*  An alternative is object security at application layer, for instance
        using {{-objsec}}.  Secure objects can be
        stored or cached in network nodes and provide security for a
        more flexible communication model such as publish/subscribe
        (compare e.g. CoRE Mirror Server {{-pubsub}}).  A
        problem with object security is that it can not provide
        confidentiality for the message headers.

*  Hybrid solutions using both session-based and object security
        are also possible.  An example of a hybrid is where
        authorization information and cryptographic keys are provided by
        AS in the format of secure data objects, but where the resource
        access is protected by session-based security.

## Cryptographic Keys

   With respect to cryptographic keys, we see the following problems
   that need to be addressed:

Symmetric vs Asymmetric Keys
:       We need keys both for protection of resource access and for
        protection of transport of authentication and authorization
        information.  It may be necessary to support solutions that require the
        use of asymmetric keys as well as ones that get by with symmetric keys, in
        both cases.

        There are classes of devices that can easily perform symmetric
        cryptography, but consume considerably more time/battery for
        asymmetric operations.  On the other hand asymmetric
        cryptography has benefits such as in terms of deployment.

Key Establishment
:       How are the corresponding cryptographic keys established?
        Considering {{probaz}} there must be a mapping between these
        keys and the authorization information, at least in the sense
        that AS must be able to specify a unique client identifier which
        RS can verify (using an associated key).

        One of the use cases of {{-usecases}} describes
        spontaneous change of access policies - such as giving a hitherto
        unknown client the right to temporarily unlock your house door.
        In this case C is not previously known to RS and a key must be
        provisioned by AS.

Revocation and Expiration
:       How are keys replaced and how is a key that has been compromised
        revoked in a manner that reaches all affected parties, also
        keeping in mind scenarios with intermittent connectivity?
{: vspace="0"}


# Assumptions and Requirements {#assreq}

   In this section we list a set of candidate assumptions and
   requirements to make the problem description in the previous sections
   more concise and precise.  Note that many of these assumptions and
   requirements are targeting specific solutions and not the
   architecture itself.

## Architecture

   The architecture consists of at least the following types of nodes:

*  RS hosting resources, and responding to access requests

*  C requesting access to resources

*  AS supporting the access request/response procedure by providing
        authorization information to RS

     - AS may support this by aiding RS in
       authenticating C, or providing cryptographic keys or
       credentials to C and/or RS to secure the request/response
       procedure.

*  CAS supporting the access request/response procedure by providing
        authorization information to C

     - CAS may support this by aiding C in
       authenticating RS, forwarding information between AS and C
       (possibly ultimately for RS), or providing cryptographic keys or
       credentials to C and/or RS to secure the request/response
       procedure.

*  The architecture allows for intermediary nodes between any pair
        of C, RS, AS, and CAS, such as forward or reverse proxies in the
        CoRE architecture.  (Solutions may or may not support all combinations.)

     - The architecture does not make a choice between session based
       security and data object security.

## Constrained Devices

*  C and/or RS may be constrained in terms of power, processing,
        communication bandwidth, memory and storage space, and moreover:

     - unable to manage complex authorization policies

     - unable to manage a large number of secure connections

     - without user interface

     - without constant network connectivity

     - unable to precisely measure time

     - required to save on wireless communication due to high power
       consumption

*  CAS and AS are not assumed to be constrained devices.

*  All devices under consideration can process symmetric
        cryptography without incurring an excessive performance penalty.

     - We assume the use of a standardized symmetric key algorithm,
       such as AES.

     - Except for the most constrained devices we assume the use of
       a standardized cryptographic hash function such as SHA-256
       (which can be used with the HMAC construction for integrity protection).

*  Public key cryptography requires additional resources (such as RAM,
        ROM, power, specialized hardware).

*  A DTLS handshake involves significant computation,
        communication, and memory overheads in the context of
        constrained devices.

     - The RAM requirements of DTLS handshakes with public key
       cryptography are prohibitive for certain constrained devices.

     - Certificate-based DTLS handshakes require significant volumes
       of communication, RAM (message buffers) and computation.

*  A solution will need to consider support for a simple scheme for expiring
        authentication and authorization information on devices which
        are unable to measure time (cf. {{time-measurements}}).

## Authentication

*  RS needs to authenticate AS to ensure that the authorization
        information and related data comes from the correct source.

*  Similarly, C needs to authenticate CAS to ensure that the authorization
        information and related data comes from the correct source.

* Depending on use case and authorization requirements, C, RS, CAS, or
        AS may need to authenticate messages from each other.

## Server-side Authorization

* RS enforces authorization for access to a resource based on
        credentials presented by C, the requested resource, the REST
        method, and local context in RS at the time of the request, or
        on any subset of this information.

* The credentials presented by C may have been provided by CAS.

*  The underlying authorization decision is taken either by AS or RS.

*  The authorization decision is enforced by RS.

     - RS needs to have authorization information in order to verify
       that C is allowed to access the resource as requested.

     - RS needs to make sure that it provides resource access only
       to authorized clients.

*  Apart from authorization for access to a resource, authorization
        may also be required for access to information about a resource
        (for instance, resource descriptions).

*  The solution may need to be able to support the delegation of
        access rights.

## Client-side Authorization Information

* C enforces client-side authorization by protecting its requests to
  RS and by authenticating results from RS, making use of decisions
  and policies as well as keying material provided by CAS.

## Server-side Authorization Information

*  Authorization information is transferred from AS to RS using
        Agent, Push or Pull mechanisms {{RFC2904}}.

*  RS needs to authenticate that the authorization information is
        coming from AS (integrity).

*  The authorization information may also be encrypted end-to-end
        between AS and RS (confidentiality).

* The architecture supports the case where RS may not be able to
        communicate with AS at the time of the request from C.

*  RS may store or cache authorization information.

*  Authorization information may be pre-configured in RS.

*  Authorization information stored or cached in RS needs to be
        possible to change.  The change of such information needs to be
        subject to authorization.

*  Authorization policies stored on RS may be handled as a
        resource, i.e. information located at a particular URI, accessed
        with RESTful methods, and the access being subject to the same
        authorization mechanics.  AS may have special privileges when
        requesting access to the authorization policy resources on RS.

*  There may be mechanisms for C to look up the AS which provides
        authorization information about a particular resource.

## Resource Access

*  Resources are accessed in a RESTful manner using methods such as GET, PUT, POST,
        DELETE.

*  By default, the resource request needs to be integrity protected
        and may be encrypted end-to-end from C to RS.  It needs to be
        possible for RS to detect a replayed request.

*  By default, the response to a request needs to be integrity
        protected and may be encrypted end-to-end from RS to C.  It needs to be
        possible for C to detect a replayed response.

*  RS needs to be able to verify that the request comes from an
        authorized client.

*  C needs to be able to verify that the response to a request comes
        from the intended RS.

*  There may be resources whose access need not be protected (e.g.
        for discovery of the responsible AS).

## Keys and Cipher Suites

* A constrained node and its authorization manager (i.e., RS and AS,
        and C and CAS) have established cryptographic keys.  For
        example, they share a secret key or each have the other's
        public key.

*  The transfer of authorization information is protected with
        symmetric and/or asymmetric keys.

*  The access request/response can be protected with symmetric
        and/or asymmetric keys.

* There must be a mechanism for RS to establish the necessary key(s)
        to verify and decrypt the request and to protect the response.

* There must be a mechanism for C to establish the necessary key(s) to
        protect the request and to verify and decrypt the response.

*  There must be a mechanism for C to obtain the supported cipher
        suites of a RS.

## Network Considerations

* A solution will need to consider network overload due to avoidable
        communication of a constrained node with its authorization
        manager (C with CAS, RS with AS).

* A solution will need to consider network overload by compact
        authorization information representation.

* A solution may want to optimize the case where authorization
        information does not change often.

* A solution may consider support for an efficient mechanism
        for providing authorization information to multiple RSs, for
        example when multiple entities need to be configured or change
        state.


## Legacy Considerations

* A solution may consider interworking with existing infrastructure.

* A solution may consider supporting authorization of access to legacy
        devices.



#  Security Considerations

This document discusses authorization-related tasks for constrained
environments and describes how these tasks can be mapped to actors in
the architecture.

   The entire document is about security.  Security considerations
   applicable to authentication and authorization in RESTful
   environments are provided in e.g. OAuth 2.0 {{RFC6749}}.

   In this section we focus on specific security aspects related to
   authorization in constrained-node networks.
   Section 11.6 of {{-coap}},
   "Constrained node considerations", discusses implications of specific
   constraints on the security mechanisms employed.  A wider
   view of security in constrained-node networks is provided in
   {{-coresec}}.

## Physical Attacks on Sensor and Actuator Networks

   The focus of this work is on constrained-node networks consisting of
   connected constrained devices such as sensors and actuators.  The main function of such devices
   is to interact with the physical world by gathering information or
   performing an action.  We now discuss attacks performed with physical
   access to such devices.

   The main threats to sensors and actuator networks are:

*  Unauthorized access to data to and from sensors and actuators,
        including eavesdropping and manipulation of data.

*  Denial-of-service making the sensor/actuator unable to perform
        its intended task correctly.

   A number of attacks can be made with physical access to a device
   including probing attacks, timing attacks, power attacks, etc.
   However, with physical access to a sensor or actuator device it is
   possible to directly perform attacks equivalent of eavesdropping,
   manipulating data or denial of service. For example:

*  Instead of eavesdropping the sensor data or attacking the
        authorization system to gain access to the data, the attacker
        could make its own measurements on the physical object.

*  Instead of manipulating the sensor data the attacker could
        change the physical object which the sensor is measuring,
        thereby changing the payload data which is being sent.

*  Instead of manipulating data for an actuator or attacking the
        authorization system, the attacker could perform an unauthorized
        action directly on the physical object.

*  A denial-of-service attack could be performed physically on the
        object or device.

   All these attacks are possible by having physical access to the
   device, since the assets are related to the physical world.
   Moreover, this kind of attacks are in many cases straightforward
   (requires no special competence or tools, low cost given physical
   access, etc.)

   As a conclusion, if an attacker has full physical access to a sensor or
   actuator device, then much of the security functionality elaborated
   in this draft may not be effective to protect the asset during the
   physical attack.

   Since it does not make sense to design a solution for a situation
   that cannot be protected against we assume there is no need to
   protect assets the secrets or functioning of which are exposed during a physical attack.  In other
   words, either an attacker does not have physical access to the
   secrets or functioning of the sensor
   or actuator device, or if it has, the attack shall only have effect
   during the period of physical attack, and shall be limited in
   extent to the physical control the attacker exerts (e.g., must not
   affect the security of other devices.)

## Clocks and Time Measurements {#time-measurements}

   Some applications may require a device to be aware of the
   wall-clock time (e.g., a door lock that opens Monday to Friday at
   specific times, except for holidays).  Other applications only need
   to be able to measure short relative time (e.g., a door lock that
   keeps the door open for ten seconds after receiving a state change
   to open; such a door lock may be limited in its time-keeping
   accuracy and may not be able to keep time across power failures).

   In addition to application requirements of this kind,
   measuring time and keeping wall-clock time with certain accuracy is
   important to achieve certain
   security properties, for example to determine whether a public key
   certificate, access token, or some other assertion, is valid.

   Dynamic authorization in itself requires the ability to handle expiry
   or revocation of authorization decisions or to distinguish new
   authorization decisions from old.

   For certain categories of devices we can assume that there is an
   internal clock which is sufficiently accurate to handle the time
   measurement requirements.  If RS can connect directly to AS, this
   relationship can be used to update RS in terms of time, removing
   some uncertainty, as well as
   to directly provide revocation information, removing authorizations
   that are no longer desired.

   If RS continuously measures time but can't connect to AS or another
   trusted source of time, time drift may have to be accepted and it may be
   harder to manage revocation.  However, RS may still be able to handle
   short lived access rights within some margins, by measuring the time
   since arrival of authorization information or request.

   Some categories of devices in scope may be unable to measure time with
   any accuracy (e.g. because of sleep cycles).  This category of
   devices is not suitable for the use cases which require measuring
   validity of assertions and authorizations in terms of absolute time.


#  IANA Considerations

This document has no actions for IANA.

--- back

#  Acknowledgements
{: numbered="no"}

The authors would like to thank Olaf Bergmann, Robert Cragie, Samuel Erdtman,
Klaus
Hartke, Sandeep Kumar, John Mattson, Corinna Schmitt, Mohit Sethi,
Abhinav Somaraju,
Hannes Tschofenig, Vlasios Tsiatsis and Erik Wahlstroem for
contributing to the discussion, giving helpful input and commenting on
previous forms of this draft.  The authors would also like to
specifically acknowledge input provided by Hummen and others
{{HUM14delegation}}.
Robin Wilton provided extensive editorial comments that were the basis
for significant improvements of the text.

<!--  LocalWords:  CoAP verifiability Misconfigured constrainedness
 -->
<!--  LocalWords:  RqP RO CAS OAuth UMA priori untrusted ROs RESTful
 -->
<!--  LocalWords:  RSs interworking
 -->

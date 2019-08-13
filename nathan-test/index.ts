/*
 * Auto-generated to TypeScript by avdl-compiler v1.4.0 (https://github.com/keybase/node-avdl-compiler)
 *   Input files:
 *   - ../client/protocol/avdl/chat1/api.avdl
 *   - ../client/protocol/avdl/chat1/chat_ui.avdl
 *   - ../client/protocol/avdl/chat1/commands.avdl
 *   - ../client/protocol/avdl/chat1/common.avdl
 *   - ../client/protocol/avdl/chat1/gregor.avdl
 *   - ../client/protocol/avdl/chat1/local.avdl
 *   - ../client/protocol/avdl/chat1/notify.avdl
 *   - ../client/protocol/avdl/chat1/remote.avdl
 *   - ../client/protocol/avdl/chat1/unfurl.avdl
 */

import * as gregor1 from 'github.com/keybase/client/go/protocol/gregor1'
import * as keybase1 from 'github.com/keybase/client/go/protocol/keybase1'
import * as stellar1 from 'github.com/keybase/client/go/protocol/stellar1'

type RateLimitRes = {
  tank: string
  capacity: number
  reset: number
  gas: number
}

type ChatChannel = {
  name: string
  public: boolean
  membersType: string
  topicType: string
  topicName: string
}

type ChatMessage = {
  body: string
}

type MsgSender = {
  uid: string
  username: string
  deviceID: string
  deviceName: string
}

type MsgFlipContent = {
  text: string
  gameID: string
  flipConvID: string
  userMentions: KnownUserMention[]
  teamMentions: KnownTeamMention[]
}

type MsgContent = {
  typeName: string
  text: MessageText
  attachment: MessageAttachment
  edit: MessageEdit
  reaction: MessageReaction
  delete: MessageDelete
  metadata: MessageConversationMetadata
  headline: MessageHeadline
  attachmentUploaded: MessageAttachmentUploaded
  system: MessageSystem
  sendPayment: MessageSendPayment
  requestPayment: MessageRequestPayment
  unfurl: MessageUnfurl
  flip: MsgFlipContent
}

type MsgSummary = {
  id: MessageID
  convID: string
  channel: ChatChannel
  sender: MsgSender
  sentAt: int64
  sentAtMs: int64
  content: MsgContent
  prev: MessagePreviousPointer[]
  unread: boolean
  revokedDevice: boolean
  offline: boolean
  kbfsEncrypted: boolean
  isEphemeral: boolean
  isEphemeralExpired: boolean
  eTime: gregor1.Time
  reactions: ReactionMap
  hasPairwiseMacs: boolean
  atMentionUsernames: string[]
  channelMention: string
  channelNameMentions: UIChannelNameMention[]
}

type Message = {
  msg: MsgSummary
  error: string
}

type Thread = {
  messages: Message[]
  pagination: Pagination
  offline: boolean
  identifyFailures: keybase1.TLFIdentifyFailure[]
  rateLimits: RateLimitRes[]
}

type ConvSummary = {
  id: string
  channel: ChatChannel
  unread: boolean
  activeAt: int64
  activeAtMs: int64
  memberStatus: string
  resetUsers: string[]
  finalizeInfo: ConversationFinalizeInfo
  supersedes: string[]
  supersededBy: string[]
  error: string
}

type ChatList = {
  conversations: ConvSummary[]
  offline: boolean
  identifyFailures: keybase1.TLFIdentifyFailure[]
  pagination: Pagination
  rateLimits: RateLimitRes[]
}

type SendRes = {
  message: string
  messageID: MessageID
  outboxID: OutboxID
  identifyFailures: keybase1.TLFIdentifyFailure[]
  rateLimits: RateLimitRes[]
}

type SearchInboxResOutput = {
  results: ChatSearchInboxResults
  identifyFailures: keybase1.TLFIdentifyFailure[]
  rateLimits: RateLimitRes[]
}

type RegexpRes = {
  hits: ChatSearchHit[]
  identifyFailures: keybase1.TLFIdentifyFailure[]
  rateLimits: RateLimitRes[]
}

type NewConvRes = {
  id: string
  identifyFailures: keybase1.TLFIdentifyFailure[]
  rateLimits: RateLimitRes[]
}

type ListCommandsRes = {
  commands: UserBotCommandOutput[]
  rateLimits: RateLimitRes[]
}

type EmptyRes = {
  rateLimits: RateLimitRes[]
}

type MsgNotification = {
  type: string
  source: string
  msg: MsgSummary
  error: string
  pagination: UIPagination
}

type UIPagination = {
  next: string
  previous: string
  num: number
  last: boolean
}

type UnverifiedInboxUIItemMetadata = {
  channelName: string
  headline: string
  headlineDecorated: string
  snippet: string
  snippetDecoration: string
  writerNames: string[]
  resetParticipants: string[]
}

type UnverifiedInboxUIItem = {
  convID: string
  topicType: TopicType
  isPublic: boolean
  name: string
  visibility: keybase1.TLFVisibility
  status: ConversationStatus
  membersType: ConversationMembersType
  memberStatus: ConversationMemberStatus
  teamType: TeamType
  notifications: ConversationNotificationInfo
  time: gregor1.Time
  version: ConversationVers
  localVersion: LocalConversationVers
  convRetention: RetentionPolicy
  teamRetention: RetentionPolicy
  maxMsgID: MessageID
  maxVisibleMsgID: MessageID
  readMsgID: MessageID
  localMetadata: UnverifiedInboxUIItemMetadata
  draft: string
  finalizeInfo: ConversationFinalizeInfo
  supersedes: ConversationMetadata[]
  supersededBy: ConversationMetadata[]
  commands: ConversationCommandGroups
}

type UnverifiedInboxUIItems = {
  items: UnverifiedInboxUIItem[]
  pagination: UIPagination
  offline: boolean
}

enum UIParticipantType {
  NONE = 0
  USER = 1
  PHONENO = 2
  EMAIL = 3
}

type UIParticipant = {
  type: UIParticipantType
  assertion: string
  fullName: string
  contactName: string
}

type InboxUIItem = {
  convID: string
  topicType: TopicType
  isPublic: boolean
  isEmpty: boolean
  name: string
  snippet: string
  snippetDecoration: string
  channel: string
  headline: string
  headlineDecorated: string
  draft: string
  visibility: keybase1.TLFVisibility
  participants: UIParticipant[]
  resetParticipants: string[]
  status: ConversationStatus
  membersType: ConversationMembersType
  memberStatus: ConversationMemberStatus
  teamType: TeamType
  time: gregor1.Time
  notifications: ConversationNotificationInfo
  creatorInfo: ConversationCreatorInfoLocal
  version: ConversationVers
  localVersion: LocalConversationVers
  maxMsgID: MessageID
  maxVisibleMsgID: MessageID
  readMsgID: MessageID
  convRetention: RetentionPolicy
  teamRetention: RetentionPolicy
  convSettings: ConversationSettingsLocal
  finalizeInfo: ConversationFinalizeInfo
  supersedes: ConversationMetadata[]
  supersededBy: ConversationMetadata[]
  commands: ConversationCommandGroups
  botCommands: ConversationCommandGroups
}

type InboxUIItemError = {
  typ: ConversationErrorType
  message: string
  unverifiedTLFName: string
  rekeyInfo: ConversationErrorRekey
  remoteConv: UnverifiedInboxUIItem
}

type InboxUIItems = {
  items: InboxUIItem[]
  pagination: UIPagination
  offline: boolean
}

type UIChannelNameMention = {
  name: string
  convID: string
}

type UIAssetUrlInfo = {
  previewUrl: string
  fullUrl: string
  fullUrlCached: boolean
  mimeType: string
  videoDuration: string
  inlineVideoPlayable: boolean
}

type UIPaymentInfo = {
  accountID: stellar1.AccountID
  amountDescription: string
  worth: string
  worthAtSendTime: string
  delta: stellar1.BalanceDelta
  note: string
  paymentID: stellar1.PaymentID
  status: stellar1.PaymentStatus
  statusDescription: string
  statusDetail: string
  showCancel: boolean
  fromUsername: string
  toUsername: string
  sourceAmount: string
  sourceAsset: stellar1.Asset
  issuerDescription: string
}

type UIRequestInfo = {
  amount: string
  amountDescription: string
  asset: stellar1.Asset
  currency: stellar1.OutsideCurrencyCode
  worthAtRequestTime: string
  status: stellar1.RequestStatus
}

type UIMessageUnfurlInfo = {
  unfurlMessageID: MessageID
  url: string
  unfurl: UnfurlDisplay
  isCollapsed: boolean
}

type UIMessageValid = {
  messageID: MessageID
  ctime: gregor1.Time
  outboxID: string
  messageBody: MessageBody
  decoratedTextBody: string
  bodySummary: string
  senderUsername: string
  senderDeviceName: string
  senderDeviceType: string
  senderUID: gregor1.UID
  senderDeviceID: gregor1.DeviceID
  superseded: boolean
  assetUrlInfo: UIAssetUrlInfo
  senderDeviceRevokedAt: gregor1.Time
  atMentions: string[]
  channelMention: ChannelMention
  channelNameMentions: UIChannelNameMention[]
  isEphemeral: boolean
  isEphemeralExpired: boolean
  explodedBy: string
  etime: gregor1.Time
  reactions: ReactionMap
  hasPairwiseMacs: boolean
  paymentInfos: UIPaymentInfo[]
  requestInfo: UIRequestInfo
  unfurls: UIMessageUnfurlInfo[]
  isCollapsed: boolean
  flipGameID: string
  isDeleteable: boolean
  isEditable: boolean
  replyTo: UIMessage
}

type UIMessageOutbox = {
  state: OutboxState
  outboxID: string
  messageType: MessageType
  body: string
  decoratedTextBody: string
  ctime: gregor1.Time
  ordinal: number
  isEphemeral: boolean
  flipGameID: string
  replyTo: UIMessage
  filename: string
  title: string
  preview: MakePreviewRes
}

enum MessageUnboxedState {
  VALID = 1
  ERROR = 2
  OUTBOX = 3
  PLACEHOLDER = 4
}

type UIMessages = {
  messages: UIMessage[]
  pagination: UIPagination
}

type UITeamMention = {
  inTeam: boolean
  open: boolean
  description: string
  numMembers: number
  publicAdmins: string[]
  convID: string
}

enum UITextDecorationTyp {
  PAYMENT = 0
  ATMENTION = 1
  CHANNELNAMEMENTION = 2
  MAYBEMENTION = 3
  LINK = 4
  MAILTO = 5
}

enum UIMaybeMentionStatus {
  UNKNOWN = 0
  USER = 1
  TEAM = 2
  NOTHING = 3
}

type UILinkDecoration = {
  display: string
  url: string
}

enum UIChatThreadStatusTyp {
  NONE = 0
  SERVER = 1
  VALIDATING = 2
  VALIDATED = 3
}

type UIChatSearchConvHit = {
  convID: string
  teamType: TeamType
  name: string
  mtime: gregor1.Time
}

type UIChatSearchConvHits = {
  hits: UIChatSearchConvHit[]
  unreadMatches: boolean
}

type UIChatPayment = {
  username: string
  fullName: string
  xlmAmount: string
  error: string
  displayAmount: string
}

type UIChatPaymentSummary = {
  xlmTotal: string
  displayTotal: string
  payments: UIChatPayment[]
}

type GiphySearchResult = {
  targetUrl: string
  previewUrl: string
  previewWidth: number
  previewHeight: number
  previewIsVideo: boolean
}

type GiphySearchResults = {
  results: GiphySearchResult[]
  galleryUrl: string
}

enum UICoinFlipPhase {
  COMMITMENT = 0
  REVEALS = 1
  COMPLETE = 2
  ERROR = 3
}

type UICoinFlipErrorParticipant = {
  user: string
  device: string
}

type UICoinFlipAbsenteeError = {
  absentees: UICoinFlipErrorParticipant[]
}

enum UICoinFlipErrorTyp {
  GENERIC = 0
  ABSENTEE = 1
  TIMEOUT = 2
  ABORTED = 3
  DUPREG = 4
  DUPCOMMITCOMPLETE = 5
  DUPREVEAL = 6
  COMMITMISMATCH = 7
}

enum UICoinFlipResultTyp {
  NUMBER = 0
  SHUFFLE = 1
  DECK = 2
  HANDS = 3
  COIN = 4
}

type UICoinFlipHand = {
  target: string
  hand: number[]
}

type UICoinFlipParticipant = {
  uid: string
  deviceID: string
  username: string
  deviceName: string
  commitment: string
  reveal: string
}

type UICoinFlipStatus = {
  gameID: string
  phase: UICoinFlipPhase
  progressText: string
  resultText: string
  commitmentVisualization: string
  revealVisualization: string
  participants: UICoinFlipParticipant[]
  errorInfo: UICoinFlipError
  resultInfo: UICoinFlipResult
}

type UICommandMarkdown = {
  body: string
  title: string
}

type LocationWatchID = uint64
enum UICommandStatusDisplayTyp {
  STATUS = 0
  WARNING = 1
  ERROR = 2
}

enum UICommandStatusActionTyp {
  APPSETTINGS = 0
}

enum UIBotCommandsUpdateStatus {
  UPTODATE = 0
  UPDATING = 1
  FAILED = 2
  BLANK = 3
}

type ConversationCommand = {
  description: string
  name: string
  usage: string
  hasHelpText: boolean
  username: string
}

enum ConversationCommandGroupsTyp {
  BUILTIN = 0
  CUSTOM = 1
  NONE = 2
}

enum ConversationBuiltinCommandTyp {
  NONE = 0
  ADHOC = 1
  SMALLTEAM = 2
  BIGTEAM = 3
  BIGTEAMGENERAL = 4
}

type ConversationCommandGroupsCustom = {
  commands: ConversationCommand[]
}

type ThreadID = Buffer
type MessageID = number
type TLFConvOrdinal = number
type TopicID = Buffer
type ConversationID = Buffer
type TLFID = Buffer
type Hash = Buffer
type InboxVers = uint64
type LocalConversationVers = uint64
type ConversationVers = uint64
type OutboxID = Buffer
type TopicNameState = Buffer
type FlipGameID = Buffer
type InboxVersInfo = {
  uid: gregor1.UID
  vers: InboxVers
}

enum ConversationExistence {
  ACTIVE = 0
  ARCHIVED = 1
  DELETED = 2
  ABANDONED = 3
}

enum ConversationMembersType {
  KBFS = 0
  TEAM = 1
  IMPTEAMNATIVE = 2
  IMPTEAMUPGRADE = 3
}

enum SyncInboxResType {
  CURRENT = 0
  INCREMENTAL = 1
  CLEAR = 2
}

enum MessageType {
  NONE = 0
  TEXT = 1
  ATTACHMENT = 2
  EDIT = 3
  DELETE = 4
  METADATA = 5
  TLFNAME = 6
  HEADLINE = 7
  ATTACHMENTUPLOADED = 8
  JOIN = 9
  LEAVE = 10
  SYSTEM = 11
  DELETEHISTORY = 12
  REACTION = 13
  SENDPAYMENT = 14
  REQUESTPAYMENT = 15
  UNFURL = 16
  FLIP = 17
}

enum TopicType {
  NONE = 0
  CHAT = 1
  DEV = 2
  KBFSFILEEDIT = 3
}

enum TeamType {
  NONE = 0
  SIMPLE = 1
  COMPLEX = 2
}

enum NotificationKind {
  GENERIC = 0
  ATMENTION = 1
}

enum GlobalAppNotificationSetting {
  NEWMESSAGES = 0
  PLAINTEXTMOBILE = 1
  PLAINTEXTDESKTOP = 2
  DEFAULTSOUNDMOBILE = 3
  DISABLETYPING = 4
}

type GlobalAppNotificationSettings = {
  settings: Map<GlobalAppNotificationSetting, boolean>
}

enum ConversationStatus {
  UNFILED = 0
  FAVORITE = 1
  IGNORED = 2
  BLOCKED = 3
  MUTED = 4
  REPORTED = 5
}

type ConversationMember = {
  uid: gregor1.UID
  convID: ConversationID
  topicType: TopicType
}

type ConversationIDMessageIDPair = {
  convID: ConversationID
  msgID: MessageID
}

type ConversationIDMessageIDPairs = {
  pairs: ConversationIDMessageIDPair[]
}

type ChannelNameMention = {
  convID: ConversationID
  topicName: string
}

enum ConversationMemberStatus {
  ACTIVE = 0
  REMOVED = 1
  LEFT = 2
  PREVIEW = 3
  RESET = 4
  NEVER_JOINED = 5
}

type Pagination = {
  next: Buffer
  previous: Buffer
  num: number
  last: boolean
  forceFirstPage: boolean
}

type RateLimit = {
  name: string
  callsRemaining: number
  windowReset: number
  maxCalls: number
}

type GetInboxQuery = {
  convID: ConversationID
  topicType: TopicType
  tlfID: TLFID
  tlfVisibility: keybase1.TLFVisibility
  before: gregor1.Time
  after: gregor1.Time
  oneChatTypePerTLF: boolean
  topicName: string
  status: ConversationStatus[]
  memberStatus: ConversationMemberStatus[]
  existences: ConversationExistence[]
  membersTypes: ConversationMembersType[]
  convIDs: ConversationID[]
  unreadOnly: boolean
  readOnly: boolean
  computeActiveList: boolean
  summarizeMaxMsgs: boolean
  skipBgLoads: boolean
}

type ConversationIDTriple = {
  tlfid: TLFID
  topicType: TopicType
  topicID: TopicID
}

type ConversationFinalizeInfo = {
  resetUser: string
  resetDate: string
  resetFull: string
  resetTimestamp: gregor1.Time
}

type ConversationResolveInfo = {
  newTLFName: string
}

type Expunge = {
  upto: MessageID
  basis: MessageID
}

type ConversationMetadata = {
  idTriple: ConversationIDTriple
  conversationID: ConversationID
  visibility: keybase1.TLFVisibility
  status: ConversationStatus
  membersType: ConversationMembersType
  teamType: TeamType
  existence: ConversationExistence
  version: ConversationVers
  localVersion: LocalConversationVers
  finalizeInfo: ConversationFinalizeInfo
  supersedes: ConversationMetadata[]
  supersededBy: ConversationMetadata[]
  activeList: gregor1.UID[]
  allList: gregor1.UID[]
  resetList: gregor1.UID[]
}

type ConversationNotificationInfo = {
  channelWide: boolean
  settings: Map<keybase1.DeviceType, Map<NotificationKind, boolean>>
}

type ConversationReaderInfo = {
  mtime: gregor1.Time
  readMsgid: MessageID
  maxMsgid: MessageID
  status: ConversationMemberStatus
}

type ConversationCreatorInfo = {
  ctime: gregor1.Time
  uid: gregor1.UID
}

type ConversationCreatorInfoLocal = {
  ctime: gregor1.Time
  username: string
}

type ConversationMinWriterRoleInfo = {
  uid: gregor1.UID
  role: keybase1.TeamRole
}

type ConversationSettings = {
  minWriterRoleInfo: ConversationMinWriterRoleInfo
}

type Conversation = {
  metadata: ConversationMetadata
  readerInfo: ConversationReaderInfo
  notifications: ConversationNotificationInfo
  maxMsgs: MessageBoxed[]
  maxMsgSummaries: MessageSummary[]
  creatorInfo: ConversationCreatorInfo
  expunge: Expunge
  convRetention: RetentionPolicy
  teamRetention: RetentionPolicy
  convSettings: ConversationSettings
}

type MessageSummary = {
  msgID: MessageID
  messageType: MessageType
  tlfName: string
  tlfPublic: boolean
  ctime: gregor1.Time
}

type Reaction = {
  ctime: gregor1.Time
  reactionMsgID: MessageID
}

type ReactionMap = {
  reactions: Map<string, Map<string, Reaction>>
}

type MessageServerHeader = {
  messageID: MessageID
  supersededBy: MessageID
  reactionIDs: MessageID[]
  unfurlIDs: MessageID[]
  replies: MessageID[]
  ctime: gregor1.Time
  now: gregor1.Time
  rtime: gregor1.Time
}

type MessagePreviousPointer = {
  id: MessageID
  hash: Hash
}

type OutboxInfo = {
  prev: MessageID
  composeTime: gregor1.Time
}

type MsgEphemeralMetadata = {
  lifetime: gregor1.DurationSec
  generation: keybase1.EkGeneration
  explodedBy: string
}

type EphemeralPurgeInfo = {
  convID: ConversationID
  isActive: boolean
  nextPurgeTime: gregor1.Time
  minUnexplodedID: MessageID
}

type MessageClientHeader = {
  conv: ConversationIDTriple
  tlfName: string
  tlfPublic: boolean
  messageType: MessageType
  supersedes: MessageID
  kbfsCryptKeysUsed: boolean
  deletes: MessageID[]
  prev: MessagePreviousPointer[]
  deleteHistory: MessageDeleteHistory
  sender: gregor1.UID
  senderDevice: gregor1.DeviceID
  merkleRoot: MerkleRoot
  outboxID: OutboxID
  outboxInfo: OutboxInfo
  ephemeralMetadata: MsgEphemeralMetadata
  pairwiseMacs: Map<keybase1.KID, Buffer>
  botUID: gregor1.UID
}

type MessageClientHeaderVerified = {
  conv: ConversationIDTriple
  tlfName: string
  tlfPublic: boolean
  messageType: MessageType
  prev: MessagePreviousPointer[]
  sender: gregor1.UID
  senderDevice: gregor1.DeviceID
  kbfsCryptKeysUsed: boolean
  merkleRoot: MerkleRoot
  outboxID: OutboxID
  outboxInfo: OutboxInfo
  ephemeralMetadata: MsgEphemeralMetadata
  rtime: gregor1.Time
  hasPairwiseMacs: boolean
  botUID: gregor1.UID
}

type EncryptedData = {
  v: number
  e: Buffer
  n: Buffer
}

type SignEncryptedData = {
  v: number
  e: Buffer
  n: Buffer
}

type SealedData = {
  v: number
  e: Buffer
  n: Buffer
}

type SignatureInfo = {
  v: number
  s: Buffer
  k: Buffer
}

type MerkleRoot = {
  seqno: number
  hash: Buffer
}

enum InboxResType {
  VERSIONHIT = 0
  FULL = 1
}

type InboxViewFull = {
  vers: InboxVers
  conversations: Conversation[]
  pagination: Pagination
}

enum RetentionPolicyType {
  NONE = 0
  RETAIN = 1
  EXPIRE = 2
  INHERIT = 3
  EPHEMERAL = 4
}

type RpRetain = {
}

type RpExpire = {
  age: gregor1.DurationSec
}

type RpInherit = {
}

type RpEphemeral = {
  age: gregor1.DurationSec
}

enum GetThreadReason {
  GENERAL = 0
  PUSH = 1
  FOREGROUND = 2
  BACKGROUNDCONVLOAD = 3
  FIXRETRY = 4
  PREPARE = 5
  SEARCHER = 6
  INDEXED_SEARCH = 7
  KBFSFILEACTIVITY = 8
  COINFLIP = 9
  BOTCOMMANDS = 10
}

enum ReIndexingMode {
  NONE = 0
  PRESEARCH_SYNC = 1
  POSTSEARCH_SYNC = 2
}

type SearchOpts = {
  isRegex: boolean
  sentBy: string
  sentTo: string
  matchMentions: boolean
  sentBefore: gregor1.Time
  sentAfter: gregor1.Time
  maxHits: number
  maxMessages: number
  beforeContext: number
  afterContext: number
  initialPagination: Pagination
  reindexMode: ReIndexingMode
  maxConvsSearched: number
  maxConvsHit: number
  convID: ConversationID
  maxNameConvs: number
}

type EmptyStruct = {
}

type ChatSearchMatch = {
  startIndex: number
  endIndex: number
  match: string
}

type ChatSearchHit = {
  beforeMessages: UIMessage[]
  hitMessage: UIMessage
  afterMessages: UIMessage[]
  matches: ChatSearchMatch[]
}

type ChatSearchInboxHit = {
  convID: ConversationID
  teamType: TeamType
  convName: string
  query: string
  time: gregor1.Time
  hits: ChatSearchHit[]
}

type ChatSearchInboxResults = {
  hits: ChatSearchInboxHit[]
  percentIndexed: number
}

type ChatSearchInboxDone = {
  numHits: number
  numConvs: number
  percentIndexed: number
  delegated: boolean
}

type ChatSearchIndexStatus = {
  percentIndexed: number
}

type AssetMetadataImage = {
  width: number
  height: number
}

type AssetMetadataVideo = {
  width: number
  height: number
  durationMs: number
}

type AssetMetadataAudio = {
  durationMs: number
}

enum AssetMetadataType {
  NONE = 0
  IMAGE = 1
  VIDEO = 2
  AUDIO = 3
}

enum AssetTag {
  PRIMARY = 0
}

type Asset = {
  filename: string
  region: string
  endpoint: string
  bucket: string
  path: string
  size: number
  mimeType: string
  encHash: Hash
  key: Buffer
  verifyKey: Buffer
  title: string
  nonce: Buffer
  metadata: AssetMetadata
  tag: AssetTag
}

enum BotCommandsAdvertisementTyp {
  PUBLIC = 0
  TLFID_MEMBERS = 1
  TLFID_CONVS = 2
}

type GenericPayload = {
  Action: string
  inboxVers: InboxVers
  convID: ConversationID
  topicType: TopicType
  unreadUpdate: UnreadUpdate
}

type NewConversationPayload = {
  Action: string
  convID: ConversationID
  inboxVers: InboxVers
  topicType: TopicType
  unreadUpdate: UnreadUpdate
}

type NewMessagePayload = {
  Action: string
  convID: ConversationID
  message: MessageBoxed
  inboxVers: InboxVers
  topicType: TopicType
  unreadUpdate: UnreadUpdate
  maxMsgs: MessageSummary[]
}

type ReadMessagePayload = {
  Action: string
  convID: ConversationID
  msgID: MessageID
  inboxVers: InboxVers
  topicType: TopicType
  unreadUpdate: UnreadUpdate
}

type SetStatusPayload = {
  Action: string
  convID: ConversationID
  status: ConversationStatus
  inboxVers: InboxVers
  topicType: TopicType
  unreadUpdate: UnreadUpdate
}

type TeamTypePayload = {
  Action: string
  convID: ConversationID
  teamType: TeamType
  inboxVers: InboxVers
  topicType: TopicType
  unreadUpdate: UnreadUpdate
}

type SetAppNotificationSettingsPayload = {
  Action: string
  convID: ConversationID
  inboxVers: InboxVers
  settings: ConversationNotificationInfo
  topicType: TopicType
  unreadUpdate: UnreadUpdate
}

type ExpungePayload = {
  Action: string
  convID: ConversationID
  inboxVers: InboxVers
  expunge: Expunge
  maxMsgs: MessageSummary[]
  topicType: TopicType
  unreadUpdate: UnreadUpdate
}

type UnreadUpdate = {
  convID: ConversationID
  unreadMessages: number
  unreadNotifyingMessages: Map<keybase1.DeviceType, number>
  compatUnreadMessages: number
  diff: boolean
}

type TLFFinalizeUpdate = {
  finalizeInfo: ConversationFinalizeInfo
  convIDs: ConversationID[]
  inboxVers: InboxVers
}

type TLFResolveUpdate = {
  convID: ConversationID
  inboxVers: InboxVers
}

type RemoteUserTypingUpdate = {
  uid: gregor1.UID
  deviceID: gregor1.DeviceID
  convID: ConversationID
  typing: boolean
}

type UpdateConversationMembership = {
  inboxVers: InboxVers
  joined: ConversationMember[]
  removed: ConversationMember[]
  reset: ConversationMember[]
  previewed: ConversationID[]
  unreadUpdate: UnreadUpdate
  unreadUpdates: UnreadUpdate[]
}

type ConversationUpdate = {
  convID: ConversationID
  existence: ConversationExistence
}

type UpdateConversations = {
  inboxVers: InboxVers
  convUpdates: ConversationUpdate[]
}

type TeamChannelUpdate = {
  teamID: TLFID
}

type SetConvRetentionUpdate = {
  inboxVers: InboxVers
  convID: ConversationID
  policy: RetentionPolicy
}

type SetTeamRetentionUpdate = {
  inboxVers: InboxVers
  teamID: keybase1.TeamID
  policy: RetentionPolicy
}

type SetConvSettingsUpdate = {
  inboxVers: InboxVers
  convID: ConversationID
  convSettings: ConversationSettings
}

type KBFSImpteamUpgradeUpdate = {
  convID: ConversationID
  inboxVers: InboxVers
  topicType: TopicType
}

type SubteamRenameUpdate = {
  convIDs: ConversationID[]
  inboxVers: InboxVers
}

type VersionKind = string
enum TextPaymentResultTyp {
  SENT = 0
  ERROR = 1
}

type TextPayment = {
  username: string
  paymentText: string
  result: TextPaymentResult
}

type KnownUserMention = {
  text: string
  uid: gregor1.UID
}

type KnownTeamMention = {
  name: string
  channel: string
}

type MaybeMention = {
  name: string
  channel: string
}

type Coordinate = {
  lat: number
  lon: number
  accuracy: number
}

type LiveLocation = {
  endTime: gregor1.Time
}

type MessageText = {
  body: string
  payments: TextPayment[]
  replyTo: MessageID
  replyToUID: gregor1.UID
  userMentions: KnownUserMention[]
  teamMentions: KnownTeamMention[]
  liveLocation: LiveLocation
}

type MessageConversationMetadata = {
  conversationTitle: string
}

type MessageEdit = {
  messageID: MessageID
  body: string
  userMentions: KnownUserMention[]
  teamMentions: KnownTeamMention[]
}

type MessageDelete = {
  messageIDs: MessageID[]
}

type MessageHeadline = {
  headline: string
}

type MessageFlip = {
  text: string
  gameID: FlipGameID
  flipConvID: ConversationID
  userMentions: KnownUserMention[]
  teamMentions: KnownTeamMention[]
}

enum MessageSystemType {
  ADDEDTOTEAM = 0
  INVITEADDEDTOTEAM = 1
  COMPLEXTEAM = 2
  CREATETEAM = 3
  GITPUSH = 4
  CHANGEAVATAR = 5
  CHANGERETENTION = 6
  BULKADDTOCONV = 7
}

type MessageSystemAddedToTeam = {
  team: string
  adder: string
  addee: string
  owners: string[]
  admins: string[]
  writers: string[]
  readers: string[]
  bots: string[]
  restrictedBots: string[]
}

type MessageSystemInviteAddedToTeam = {
  team: string
  inviter: string
  invitee: string
  adder: string
  inviteType: keybase1.TeamInviteCategory
}

type MessageSystemComplexTeam = {
  team: string
}

type MessageSystemCreateTeam = {
  team: string
  creator: string
}

type MessageSystemGitPush = {
  team: string
  pusher: string
  repoName: string
  repoID: keybase1.RepoID
  refs: keybase1.GitRefMetadata[]
  pushType: keybase1.GitPushType
  previousRepoName: string
}

type MessageSystemChangeAvatar = {
  team: string
  user: string
}

type MessageSystemChangeRetention = {
  isTeam: boolean
  isInherit: boolean
  membersType: ConversationMembersType
  policy: RetentionPolicy
  user: string
}

type MessageSystemBulkAddToConv = {
  usernames: string[]
}

type MessageDeleteHistory = {
  upto: MessageID
}

type MessageAttachment = {
  object: Asset
  preview: Asset
  previews: Asset[]
  metadata: Buffer
  uploaded: boolean
}

type MessageAttachmentUploaded = {
  messageID: MessageID
  object: Asset
  previews: Asset[]
  metadata: Buffer
}

type MessageJoin = {
  joiners: string[]
  leavers: string[]
}

type MessageLeave = {
}

type MessageReaction = {
  messageID: MessageID
  body: string
}

type MessageSendPayment = {
  paymentID: stellar1.PaymentID
}

type MessageRequestPayment = {
  requestID: stellar1.KeybaseRequestID
  note: string
}

type MessageUnfurl = {
  unfurl: UnfurlResult
  messageID: MessageID
}

type SenderPrepareOptions = {
  skipTopicNameState: boolean
  replyTo: MessageID
}

type SenderSendOptions = {
  joinMentionsAs: ConversationMemberStatus
}

enum OutboxStateType {
  SENDING = 0
  ERROR = 1
}

enum OutboxErrorType {
  MISC = 0
  OFFLINE = 1
  IDENTIFY = 2
  TOOLONG = 3
  DUPLICATE = 4
  EXPIRED = 5
  TOOMANYATTEMPTS = 6
  ALREADY_DELETED = 7
  UPLOADFAILED = 8
}

type OutboxStateError = {
  message: string
  typ: OutboxErrorType
}

type OutboxRecord = {
  state: OutboxState
  outboxID: OutboxID
  convID: ConversationID
  ctime: gregor1.Time
  Msg: MessagePlaintext
  identifyBehavior: keybase1.TLFIdentifyBehavior
  prepareOpts: SenderPrepareOptions
  sendOpts: SenderSendOptions
  ordinal: number
  preview: MakePreviewRes
  replyTo: MessageUnboxed
}

enum HeaderPlaintextVersion {
  V1 = 1
  V2 = 2
  V3 = 3
  V4 = 4
  V5 = 5
  V6 = 6
  V7 = 7
  V8 = 8
  V9 = 9
  V10 = 10
}

type HeaderPlaintextMetaInfo = {
  crit: boolean
}

type HeaderPlaintextUnsupported = {
  mi: HeaderPlaintextMetaInfo
}

type HeaderPlaintextV1 = {
  conv: ConversationIDTriple
  tlfName: string
  tlfPublic: boolean
  messageType: MessageType
  prev: MessagePreviousPointer[]
  sender: gregor1.UID
  senderDevice: gregor1.DeviceID
  kbfsCryptKeysUsed: boolean
  bodyHash: Hash
  outboxInfo: OutboxInfo
  outboxID: OutboxID
  headerSignature: SignatureInfo
  merkleRoot: MerkleRoot
  ephemeralMetadata: MsgEphemeralMetadata
  botUID: gregor1.UID
}

enum BodyPlaintextVersion {
  V1 = 1
  V2 = 2
  V3 = 3
  V4 = 4
  V5 = 5
  V6 = 6
  V7 = 7
  V8 = 8
  V9 = 9
  V10 = 10
}

type BodyPlaintextMetaInfo = {
  crit: boolean
}

type BodyPlaintextUnsupported = {
  mi: BodyPlaintextMetaInfo
}

type BodyPlaintextV1 = {
  messageBody: MessageBody
}

type MessagePlaintext = {
  clientHeader: MessageClientHeader
  messageBody: MessageBody
  supersedesOutboxID: OutboxID
}

type MessageUnboxedValid = {
  clientHeader: MessageClientHeaderVerified
  serverHeader: MessageServerHeader
  messageBody: MessageBody
  senderUsername: string
  senderDeviceName: string
  senderDeviceType: string
  bodyHash: Hash
  headerHash: Hash
  headerSignature: SignatureInfo
  verificationKey: Buffer
  senderDeviceRevokedAt: gregor1.Time
  atMentionUsernames: string[]
  atMentions: gregor1.UID[]
  channelMention: ChannelMention
  maybeMentions: MaybeMention[]
  channelNameMentions: ChannelNameMention[]
  reactions: ReactionMap
  unfurls: Map<MessageID, UnfurlResult>
  replyTo: MessageUnboxed
}

enum MessageUnboxedErrorType {
  MISC = 0
  BADVERSION_CRITICAL = 1
  BADVERSION = 2
  IDENTIFY = 3
  EPHEMERAL = 4
  PAIRWISE_MISSING = 5
}

type MessageUnboxedError = {
  errType: MessageUnboxedErrorType
  errMsg: string
  internalErrMsg: string
  versionKind: VersionKind
  versionNumber: number
  isCritical: boolean
  senderUsername: string
  senderDeviceName: string
  senderDeviceType: string
  messageID: MessageID
  messageType: MessageType
  ctime: gregor1.Time
  isEphemeral: boolean
  isEphemeralExpired: boolean
  etime: gregor1.Time
}

type MessageUnboxedPlaceholder = {
  messageID: MessageID
  hidden: boolean
}

type UnreadFirstNumLimit = {
  NumRead: number
  AtLeast: number
  AtMost: number
}

type ConversationLocalParticipant = {
  username: string
  fullname: string
  contactName: string
}

type ConversationInfoLocal = {
  id: ConversationID
  triple: ConversationIDTriple
  tlfName: string
  topicName: string
  headline: string
  snippetMsg: MessageUnboxed
  draft: string
  visibility: keybase1.TLFVisibility
  status: ConversationStatus
  membersType: ConversationMembersType
  memberStatus: ConversationMemberStatus
  teamType: TeamType
  existence: ConversationExistence
  version: ConversationVers
  localVersion: LocalConversationVers
  participants: ConversationLocalParticipant[]
  finalizeInfo: ConversationFinalizeInfo
  resetNames: string[]
}

enum ConversationErrorType {
  PERMANENT = 0
  MISSINGINFO = 1
  SELFREKEYNEEDED = 2
  OTHERREKEYNEEDED = 3
  IDENTIFY = 4
  TRANSIENT = 5
  NONE = 6
}

type ConversationErrorLocal = {
  typ: ConversationErrorType
  message: string
  remoteConv: Conversation
  unverifiedTLFName: string
  rekeyInfo: ConversationErrorRekey
}

type ConversationErrorRekey = {
  tlfName: string
  tlfPublic: boolean
  rekeyers: string[]
  writerNames: string[]
  readerNames: string[]
}

type ConversationMinWriterRoleInfoLocal = {
  changedBy: string
  cannotWrite: boolean
  role: keybase1.TeamRole
}

type ConversationSettingsLocal = {
  minWriterRoleInfo: ConversationMinWriterRoleInfoLocal
}

type ConversationLocal = {
  error: ConversationErrorLocal
  info: ConversationInfoLocal
  readerInfo: ConversationReaderInfo
  creatorInfo: ConversationCreatorInfoLocal
  notifications: ConversationNotificationInfo
  supersedes: ConversationMetadata[]
  supersededBy: ConversationMetadata[]
  maxMessages: MessageSummary[]
  isEmpty: boolean
  identifyFailures: keybase1.TLFIdentifyFailure[]
  expunge: Expunge
  convRetention: RetentionPolicy
  teamRetention: RetentionPolicy
  convSettings: ConversationSettingsLocal
  commands: ConversationCommandGroups
  botCommands: ConversationCommandGroups
}

type NonblockFetchRes = {
  offline: boolean
  rateLimits: RateLimit[]
  identifyFailures: keybase1.TLFIdentifyFailure[]
}

type ThreadView = {
  messages: MessageUnboxed[]
  pagination: Pagination
}

enum MessageIDControlMode {
  OLDERMESSAGES = 0
  NEWERMESSAGES = 1
  CENTERED = 2
  UNREADLINE = 3
}

type MessageIDControl = {
  pivot: MessageID
  mode: MessageIDControlMode
  num: number
}

type GetThreadQuery = {
  markAsRead: boolean
  messageTypes: MessageType[]
  disableResolveSupersedes: boolean
  enableDeletePlaceholders: boolean
  disablePostProcessThread: boolean
  before: gregor1.Time
  after: gregor1.Time
  messageIDControl: MessageIDControl
}

type GetThreadLocalRes = {
  thread: ThreadView
  offline: boolean
  rateLimits: RateLimit[]
  identifyFailures: keybase1.TLFIdentifyFailure[]
}

enum GetThreadNonblockCbMode {
  FULL = 0
  INCREMENTAL = 1
}

enum GetThreadNonblockPgMode {
  DEFAULT = 0
  SERVER = 1
}

type UnreadlineRes = {
  offline: boolean
  rateLimits: RateLimit[]
  identifyFailures: keybase1.TLFIdentifyFailure[]
  unreadlineID: MessageID
}

type NameQuery = {
  name: string
  tlfID: TLFID
  membersType: ConversationMembersType
}

type GetInboxLocalQuery = {
  name: NameQuery
  topicName: string
  convIDs: ConversationID[]
  topicType: TopicType
  tlfVisibility: keybase1.TLFVisibility
  before: gregor1.Time
  after: gregor1.Time
  oneChatTypePerTLF: boolean
  status: ConversationStatus[]
  memberStatus: ConversationMemberStatus[]
  unreadOnly: boolean
  readOnly: boolean
  computeActiveList: boolean
}

type GetInboxAndUnboxLocalRes = {
  conversations: ConversationLocal[]
  pagination: Pagination
  offline: boolean
  rateLimits: RateLimit[]
  identifyFailures: keybase1.TLFIdentifyFailure[]
}

type GetInboxAndUnboxUILocalRes = {
  conversations: InboxUIItem[]
  pagination: Pagination
  offline: boolean
  rateLimits: RateLimit[]
  identifyFailures: keybase1.TLFIdentifyFailure[]
}

type PostLocalRes = {
  rateLimits: RateLimit[]
  messageID: MessageID
  identifyFailures: keybase1.TLFIdentifyFailure[]
}

type PostLocalNonblockRes = {
  rateLimits: RateLimit[]
  outboxID: OutboxID
  identifyFailures: keybase1.TLFIdentifyFailure[]
}

type EditTarget = {
  messageID: MessageID
  outboxID: OutboxID
}

type SetConversationStatusLocalRes = {
  rateLimits: RateLimit[]
  identifyFailures: keybase1.TLFIdentifyFailure[]
}

type NewConversationLocalRes = {
  conv: ConversationLocal
  uiConv: InboxUIItem
  rateLimits: RateLimit[]
  identifyFailures: keybase1.TLFIdentifyFailure[]
}

type GetInboxSummaryForCLILocalQuery = {
  topicType: TopicType
  after: string
  before: string
  visibility: keybase1.TLFVisibility
  status: ConversationStatus[]
  unreadFirst: boolean
  unreadFirstLimit: UnreadFirstNumLimit
  activitySortedLimit: number
}

type GetInboxSummaryForCLILocalRes = {
  conversations: ConversationLocal[]
  offline: boolean
  rateLimits: RateLimit[]
}

type GetConversationForCLILocalQuery = {
  markAsRead: boolean
  MessageTypes: MessageType[]
  Since: string
  limit: UnreadFirstNumLimit
  conv: ConversationLocal
}

type GetConversationForCLILocalRes = {
  conversation: ConversationLocal
  messages: MessageUnboxed[]
  offline: boolean
  rateLimits: RateLimit[]
}

type GetMessagesLocalRes = {
  messages: MessageUnboxed[]
  offline: boolean
  rateLimits: RateLimit[]
  identifyFailures: keybase1.TLFIdentifyFailure[]
}

type PostFileAttachmentArg = {
  conversationID: ConversationID
  tlfName: string
  visibility: keybase1.TLFVisibility
  filename: string
  title: string
  metadata: Buffer
  identifyBehavior: keybase1.TLFIdentifyBehavior
  callerPreview: MakePreviewRes
  outboxID: OutboxID
  ephemeralLifetime: gregor1.DurationSec
}

type GetNextAttachmentMessageLocalRes = {
  message: UIMessage
  offline: boolean
  rateLimits: RateLimit[]
  identifyFailures: keybase1.TLFIdentifyFailure[]
}

type DownloadAttachmentLocalRes = {
  rateLimits: RateLimit[]
  identifyFailures: keybase1.TLFIdentifyFailure[]
}

type DownloadFileAttachmentLocalRes = {
  filename: string
  rateLimits: RateLimit[]
  identifyFailures: keybase1.TLFIdentifyFailure[]
}

enum PreviewLocationTyp {
  URL = 0
  FILE = 1
  BYTES = 2
}

type MakePreviewRes = {
  mimeType: string
  previewMimeType: string
  location: PreviewLocation
  metadata: AssetMetadata
  baseMetadata: AssetMetadata
}

type MarkAsReadLocalRes = {
  offline: boolean
  rateLimits: RateLimit[]
}

type FindConversationsLocalRes = {
  conversations: ConversationLocal[]
  uiConversations: InboxUIItem[]
  offline: boolean
  rateLimits: RateLimit[]
  identifyFailures: keybase1.TLFIdentifyFailure[]
}

type JoinLeaveConversationLocalRes = {
  offline: boolean
  rateLimits: RateLimit[]
}

type PreviewConversationLocalRes = {
  conv: InboxUIItem
  offline: boolean
  rateLimits: RateLimit[]
}

type DeleteConversationLocalRes = {
  offline: boolean
  rateLimits: RateLimit[]
}

type GetTLFConversationsLocalRes = {
  convs: InboxUIItem[]
  offline: boolean
  rateLimits: RateLimit[]
}

type SetAppNotificationSettingsLocalRes = {
  offline: boolean
  rateLimits: RateLimit[]
}

type AppNotificationSettingLocal = {
  deviceType: keybase1.DeviceType
  kind: NotificationKind
  enabled: boolean
}

type SearchRegexpRes = {
  offline: boolean
  hits: ChatSearchHit[]
  rateLimits: RateLimit[]
  identifyFailures: keybase1.TLFIdentifyFailure[]
}

type SearchInboxRes = {
  offline: boolean
  res: ChatSearchInboxResults
  rateLimits: RateLimit[]
  identifyFailures: keybase1.TLFIdentifyFailure[]
}

type ProfileSearchConvStats = {
  err: string
  convName: string
  minConvID: MessageID
  maxConvID: MessageID
  numMissing: number
  numMessages: number
  indexSizeDisk: number
  indexSizeMem: int64
  durationMsec: gregor1.DurationMsec
  percentIndexed: number
}

type BuiltinCommandGroup = {
  typ: ConversationBuiltinCommandTyp
  commands: ConversationCommand[]
}

type StaticConfig = {
  deletableByDeleteHistory: MessageType[]
  builtinCommands: BuiltinCommandGroup[]
}

enum UnfurlPromptAction {
  ALWAYS = 0
  NEVER = 1
  ACCEPT = 2
  NOTNOW = 3
  ONETIME = 4
}

enum GalleryItemTyp {
  MEDIA = 0
  LINK = 1
  DOC = 2
}

type LoadGalleryRes = {
  messages: UIMessage[]
  last: boolean
  rateLimits: RateLimit[]
  identifyFailures: keybase1.TLFIdentifyFailure[]
}

type LoadFlipRes = {
  status: UICoinFlipStatus
  rateLimits: RateLimit[]
  identifyFailures: keybase1.TLFIdentifyFailure[]
}

type UserBotExtendedDescription = {
  title: string
  desktopBody: string
  mobileBody: string
}

type UserBotCommandOutput = {
  name: string
  description: string
  usage: string
  extendedDescription: UserBotExtendedDescription
  username: string
}

type UserBotCommandInput = {
  name: string
  description: string
  usage: string
  extendedDescription: UserBotExtendedDescription
}

type AdvertiseCommandsParam = {
  typ: BotCommandsAdvertisementTyp
  commands: UserBotCommandInput[]
  teamName: string
}

type AdvertiseBotCommandsLocalRes = {
  rateLimits: RateLimit[]
}

type ListBotCommandsLocalRes = {
  commands: UserBotCommandOutput[]
  rateLimits: RateLimit[]
}

type ClearBotCommandsLocalRes = {
  rateLimits: RateLimit[]
}

enum ChatActivitySource {
  LOCAL = 0
  REMOTE = 1
}

enum ChatActivityType {
  RESERVED = 0
  INCOMING_MESSAGE = 1
  READ_MESSAGE = 2
  NEW_CONVERSATION = 3
  SET_STATUS = 4
  FAILED_MESSAGE = 5
  MEMBERS_UPDATE = 6
  SET_APP_NOTIFICATION_SETTINGS = 7
  TEAMTYPE = 8
  EXPUNGE = 9
  EPHEMERAL_PURGE = 10
  REACTION_UPDATE = 11
  MESSAGES_UPDATED = 12
  CONVS_UPDATED = 13
}

type IncomingMessage = {
  message: UIMessage
  modifiedMessage: UIMessage
  convID: ConversationID
  displayDesktopNotification: boolean
  desktopNotificationSnippet: string
  conv: InboxUIItem
  pagination: UIPagination
}

type ReadMessageInfo = {
  convID: ConversationID
  msgID: MessageID
  conv: InboxUIItem
}

type NewConversationInfo = {
  convID: ConversationID
  conv: InboxUIItem
}

type SetStatusInfo = {
  convID: ConversationID
  status: ConversationStatus
  conv: InboxUIItem
}

type SetAppNotificationSettingsInfo = {
  convID: ConversationID
  settings: ConversationNotificationInfo
}

type FailedMessageInfo = {
  outboxRecords: OutboxRecord[]
  isEphemeralPurge: boolean
}

type MemberInfo = {
  member: string
  status: ConversationMemberStatus
}

type MembersUpdateInfo = {
  convID: ConversationID
  members: MemberInfo[]
}

type TeamTypeInfo = {
  convID: ConversationID
  teamType: TeamType
  conv: InboxUIItem
}

type ExpungeInfo = {
  convID: ConversationID
  expunge: Expunge
  conv: InboxUIItem
}

type EphemeralPurgeNotifInfo = {
  convID: ConversationID
  msgs: UIMessage[]
}

type ReactionUpdate = {
  reactions: ReactionMap
  targetMsgID: MessageID
}

type ReactionUpdateNotif = {
  convID: ConversationID
  userReacjis: keybase1.UserReacjis
  reactionUpdates: ReactionUpdate[]
}

type MessagesUpdated = {
  convID: ConversationID
  updates: UIMessage[]
}

type ConvsUpdated = {
  items: InboxUIItem[]
}

type TyperInfo = {
  uid: keybase1.UID
  username: string
  deviceID: keybase1.DeviceID
  deviceName: string
  deviceType: string
}

type ConvTypingUpdate = {
  convID: ConversationID
  typers: TyperInfo[]
}

enum StaleUpdateType {
  CLEAR = 0
  NEWACTIVITY = 1
  CONVUPDATE = 2
}

type ConversationStaleUpdate = {
  convID: ConversationID
  updateType: StaleUpdateType
}

type ChatSyncIncrementalConv = {
  conv: UnverifiedInboxUIItem
  shouldUnbox: boolean
}

type ChatSyncIncrementalInfo = {
  items: ChatSyncIncrementalConv[]
  removals: string[]
}

type MessageBoxed = {
  version: MessageBoxedVersion
  serverHeader: MessageServerHeader
  clientHeader: MessageClientHeader
  headerCiphertext: SealedData
  bodyCiphertext: EncryptedData
  verifyKey: Buffer
  keyGeneration: number
}

enum MessageBoxedVersion {
  VNONE = 0
  V1 = 1
  V2 = 2
  V3 = 3
  V4 = 4
}

type ThreadViewBoxed = {
  messages: MessageBoxed[]
  pagination: Pagination
}

type GetInboxRemoteRes = {
  inbox: InboxView
  rateLimit: RateLimit
}

type GetInboxByTLFIDRemoteRes = {
  convs: Conversation[]
  rateLimit: RateLimit
}

type GetThreadRemoteRes = {
  thread: ThreadViewBoxed
  membersType: ConversationMembersType
  visibility: keybase1.TLFVisibility
  rateLimit: RateLimit
}

type GetConversationMetadataRemoteRes = {
  conv: Conversation
  rateLimit: RateLimit
}

type PostRemoteRes = {
  msgHeader: MessageServerHeader
  rateLimit: RateLimit
}

type NewConversationRemoteRes = {
  convID: ConversationID
  createdComplexTeam: boolean
  rateLimit: RateLimit
}

type GetMessagesRemoteRes = {
  msgs: MessageBoxed[]
  rateLimit: RateLimit
}

type MarkAsReadRes = {
  rateLimit: RateLimit
}

type SetConversationStatusRes = {
  rateLimit: RateLimit
}

type GetPublicConversationsRes = {
  conversations: Conversation[]
  rateLimit: RateLimit
}

type GetUnreadlineRemoteRes = {
  unreadlineID: MessageID
  rateLimit: RateLimit
}

enum ChannelMention {
  NONE = 0
  ALL = 1
  HERE = 2
}

type UnreadUpdateFull = {
  ignore: boolean
  inboxVers: InboxVers
  inboxSyncStatus: SyncInboxResType
  updates: UnreadUpdate[]
}

type S3Params = {
  bucket: string
  objectKey: string
  accessKey: string
  acl: string
  regionName: string
  regionEndpoint: string
  regionBucketEndpoint: string
}

type SyncIncrementalRes = {
  vers: InboxVers
  convs: Conversation[]
}

type ServerCacheVers = {
  inboxVers: number
  bodiesVers: number
}

type SyncChatRes = {
  cacheVers: ServerCacheVers
  inboxRes: SyncInboxRes
}

enum SyncAllProtVers {
  V0 = 0
  V1 = 1
}

enum SyncAllNotificationType {
  STATE = 0
  INCREMENTAL = 1
}

type SyncAllResult = {
  auth: gregor1.AuthResult
  chat: SyncChatRes
  notification: SyncAllNotificationRes
  badge: UnreadUpdateFull
}

type JoinLeaveConversationRemoteRes = {
  rateLimit: RateLimit
}

type DeleteConversationRemoteRes = {
  rateLimit: RateLimit
}

type GetMessageBeforeRes = {
  msgID: MessageID
  rateLimit: RateLimit
}

type GetTLFConversationsRes = {
  conversations: Conversation[]
  rateLimit: RateLimit
}

type SetAppNotificationSettingsRes = {
  rateLimit: RateLimit
}

type SetRetentionRes = {
  rateLimit: RateLimit
}

type SetConvMinWriterRoleRes = {
  rateLimit: RateLimit
}

type SweepRes = {
  foundTask: boolean
  deletedMessages: boolean
  expunge: Expunge
}

type ServerNowRes = {
  rateLimit: RateLimit
  now: gregor1.Time
}

enum ExternalAPIKeyTyp {
  GOOGLEMAPS = 0
  GIPHY = 1
}

type CommandConvVers = uint64
type RemoteBotCommandsAdvertisementPublic = {
  convID: ConversationID
}

type RemoteBotCommandsAdvertisementTLFID = {
  convID: ConversationID
  tlfID: TLFID
}

type BotCommandConv = {
  uid: gregor1.UID
  convID: ConversationID
  vers: CommandConvVers
  mtime: gregor1.Time
}

type BotInfo = {
  commandConvs: BotCommandConv[]
}

type AdvertiseBotCommandsRes = {
  rateLimit: RateLimit
}

type ClearBotCommandsRes = {
  rateLimit: RateLimit
}

enum BotInfoResponseTyp {
  UPTODATE = 0
  INFO = 1
}

type GetBotInfoRes = {
  response: BotInfoResponse
  rateLimit: RateLimit
}

type BotInfoHash = Buffer
enum UnfurlType {
  GENERIC = 0
  YOUTUBE = 1
  GIPHY = 2
  MAPS = 3
}

type UnfurlVideo = {
  url: string
  mimeType: string
  height: number
  width: number
}

type UnfurlGenericRaw = {
  title: string
  url: string
  siteName: string
  faviconUrl: string
  imageUrl: string
  video: UnfurlVideo
  publishTime: number
  description: string
}

type UnfurlYoutubeRaw = {
}

type UnfurlGiphyRaw = {
  imageUrl: string
  video: UnfurlVideo
  faviconUrl: string
}

type UnfurlMapsRaw = {
  title: string
  url: string
  siteName: string
  imageUrl: string
  historyImageUrl: string
  description: string
}

type UnfurlGeneric = {
  title: string
  url: string
  siteName: string
  favicon: Asset
  image: Asset
  publishTime: number
  description: string
}

type UnfurlYoutube = {
}

type UnfurlGiphy = {
  favicon: Asset
  image: Asset
  video: Asset
}

type UnfurlResult = {
  unfurl: Unfurl
  url: string
}

type UnfurlImageDisplay = {
  url: string
  height: number
  width: number
  isVideo: boolean
}

type UnfurlGenericDisplay = {
  title: string
  url: string
  siteName: string
  favicon: UnfurlImageDisplay
  media: UnfurlImageDisplay
  publishTime: number
  description: string
}

type UnfurlYoutubeDisplay = {
}

type UnfurlGiphyDisplay = {
  favicon: UnfurlImageDisplay
  image: UnfurlImageDisplay
  video: UnfurlImageDisplay
}

enum UnfurlMode {
  ALWAYS = 0
  NEVER = 1
  WHITELISTED = 2
}

type UnfurlSettings = {
  mode: UnfurlMode
  whitelist: Map<string, boolean>
}

type UnfurlSettingsDisplay = {
  mode: UnfurlMode
  whitelist: string[]
}

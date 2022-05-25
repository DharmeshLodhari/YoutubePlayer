const String USER_TABLE = "User";
const String JWT_TABLE = "Jwt";
const String DEVICE_TABLE = "Device";
const String CHAT_USER_TABLE = "ChatUser";
const String SOCKET_QUEUE_TABLE = "SocketQueueChatMessage";
const String USER_CONNECTION_TABLE = "UserConnection";
const String CHAT_MESSAGE_TABLE = "ChatMessage";
const String CHAT_MESSAGE_PAGINATION_TABLE = "ChatMessagePagination";
const String NUDGE_NOTIFICATION_TABLE = "NudgeNotification";
const String NOTIFICATION_TABLE = "Notification";
const String VIRTUAL_ACCOUNT_TABLE = "VirtualAccount";
const String APP_SETTING_TABLE = "GeneralSettings";
const String FEE_STRUCTURE = "FeeStructure";
const String DOWNLOAD_FILE_IN_CHAT_TABLE = "DownloadFileInChatTable";

final initialDBSchema = [
  // Create the user table
  '''CREATE TABLE $USER_TABLE (
      "id"	INTEGER PRIMARY KEY AUTOINCREMENT,
      "uuid"	TEXT,
      "fullName"	TEXT,
      "userName"	TEXT,
      "phoneNumber"	TEXT,
      "nickname" TEXT,
      "password"	TEXT,
      "avatar"	TEXT,
      "qrCode"	TEXT,
      "rating" REAL,
      "url"	TEXT,
      "currency"	TEXT);
    ''',

  //Create download file in chat table
  '''CREATE TABLE $DOWNLOAD_FILE_IN_CHAT_TABLE (
      "check_id" TEXT,
      "conversation_id" TEXT,
      "file_path_in_os" TEXT UNIQUE,
      UNIQUE(check_id,conversation_id) 
      );
    ''',

  // Create the jwt table
  '''CREATE TABLE $JWT_TABLE (
      "id"	INTEGER PRIMARY KEY AUTOINCREMENT,
      "access"	TEXT,
      "refresh"	TEXT,
      "expiration"	TEXT);
    ''',
  // Create the device table
  '''CREATE TABLE $DEVICE_TABLE (
      "id"	INTEGER PRIMARY KEY AUTOINCREMENT,
      "firebaseToken"	TEXT,
      "type"	TEXT,
      "mode"	TEXT,
      "deviceId"	TEXT,
      "deviceName"	TEXT);
      ''',
  // Create the ChatUser table which will handle count of the messages in user connection
  '''CREATE TABLE $CHAT_USER_TABLE (
      "id"	INTEGER PRIMARY KEY AUTOINCREMENT,
      "conversationId" TEXT UNIQUE,
      "messageCount" INTEGER,
      "hashedMessage" TEXT UNIQUE);
    ''',
  // Create the SocketQueueChatMessage table which will store all the sent messages when user is offline
  '''CREATE TABLE $SOCKET_QUEUE_TABLE (
      "id" INTEGER PRIMARY KEY AUTOINCREMENT,
      "check_id" TEXT UNIQUE,
      "conversation_id" TEXT,
      "author" TEXT,
      "author_full_name" TEXT,
      "author_avatar" TEXT,
      "message" TEXT,
      "kind" TEXT,
      "read_by_author" INTEGER,
      "read_by_recipient" INTEGER,
      "delivered" INTEGER,
      "created_at" TEXT,
      "type" TEXT,
      "replied_to" TEXT);
    ''',
  // Create the userConnections table
  '''CREATE TABLE $USER_CONNECTION_TABLE (
      "id"	INTEGER PRIMARY KEY AUTOINCREMENT,
      "conversation_id" TEXT UNIQUE,
      "full_name" TEXT,
      "username" TEXT,
      "avatar" TEXT,
      "qr_code" TEXT,
      "type" TEXT,
      "created_at" INTEGER,
      "admin_users" TEXT,
      "blocked_participants" TEXT,
      "description" TEXT,
      "is_group_conversation" INTEGER,
      "muted_participants" TEXT,
      "owner" TEXT,
      "participants" TEXT,
      "last_message_time" INTEGER
   );
    ''',
  // Create the ChatMessage table
  '''CREATE TABLE $CHAT_MESSAGE_TABLE (
      "id"	INTEGER PRIMARY KEY AUTOINCREMENT,
      "author" TEXT,
      "author_full_name" TEXT,
      "check_id" TEXT,
      "created_at" INTEGER,
      "updated_at" INTEGER,
      "meta_data" TEXT,
      "deleted_for_author" INTEGER,
      "deleted_for_recipient" INTEGER,
      "delivered" INTEGER,
      "message_id" TEXT,
      "kind" TEXT,
      "media" TEXT,
      "poster" TEXT,
      "read_by_author" INTEGER,
      "read_by_recipient" INTEGER,
      "from_customer_avatar" TEXT,
      "to_customer_avatar" TEXT,
      "replied_to" TEXT,
      "text" TEXT,
      "type" TEXT,
      "was_edited" INTEGER,
      "conversation_id" TEXT,
      FOREIGN KEY(conversation_id) REFERENCES UserConnection(conversation_id) ON DELETE CASCADE,
      UNIQUE(check_id,conversation_id)
   );
    ''',
  // Create the ChatMessagePagination table
  '''CREATE TABLE $CHAT_MESSAGE_PAGINATION_TABLE (
      "id"	INTEGER PRIMARY KEY AUTOINCREMENT,
      "conversation_id" TEXT UNIQUE,
      "count" INTEGER,
      "next" TEXT,
      "previous" TEXT
    );
    ''',
  // Create the NudgeNotification table
  '''CREATE TABLE $NUDGE_NOTIFICATION_TABLE (     
            "id"	INTEGER PRIMARY KEY AUTOINCREMENT,
            "check_id" TEXT,
            "conversation_id" TEXT,
            "notification_id" TEXT,
            "author" TEXT,
            "recipient" TEXT,
            "created_at" TEXT,
            "acknowledgement_type" TEXT,
            "author_avatar" TEXT,
            "actions" TEXT,
            "type" TEXT,
            "recipient_username" TEXT
          );
    ''',
  // Create the Notification table
  '''CREATE TABLE $NOTIFICATION_TABLE (     
            "id"	INTEGER PRIMARY KEY AUTOINCREMENT,
            "notification" TEXT
          );
    ''',
  // Create the Virtual Bank Account table
  '''CREATE TABLE $VIRTUAL_ACCOUNT_TABLE (     
            "id"	INTEGER PRIMARY KEY AUTOINCREMENT,
            "account_number" TEXT,
            "financial_institution" TEXT,
            "account_name" TEXT,
            "customer_username" TEXT,
            "is_active" INTEGER,
            "created_at" TEXT,
            "updated_at" TEXT,
            "note" TEXT,
            "account_tier" TEXT
          );
    ''',
  // Create the General Settings table
  '''CREATE TABLE $APP_SETTING_TABLE (     
            "id"	INTEGER PRIMARY KEY AUTOINCREMENT,
            "playIncomingMessageSound" INTEGER,
            "playOutgoingMessageSound" INTEGER
          );
    ''',

  // Create the Fee Structure table
  '''CREATE TABLE $FEE_STRUCTURE (     
          "id"	INTEGER PRIMARY KEY AUTOINCREMENT,
          "customer_api_transaction_fee" INTEGER,
          "business_transaction_fee" INTEGER,
          "magic_envelope_fee" INTEGER,
          "empty_envelope_fee" INTEGER,
          "anonymous_transaction_fee" INTEGER,
          "tax_rate" INTEGER,
          "country" TEXT,
          "currency" TEXT
        );
    '''
];

///Add List Of Migration query's when app is in production
List<String> dbMigrations = [];

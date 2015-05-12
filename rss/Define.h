//-- 全カテゴリと各フィードの未読数の収得
#define UNREAD_COUNT @"https://sandbox.feedly.com/v3/markers/counts"

//-- カテゴリ一覧を収得
#define CATEGORY @"https://sandbox.feedly.com/v3/categories"

//-- Streams
#define STREAMS @"https://sandbox.feedly.com/v3/streams/contents?streamId=user/"

//-- フィードを新しい順で収得
#define FEED @"/category/global.all&count="

//-- savedのフィードを収得
#define SAVED @"/tag/global.saved"

//-- キャッシュの整合性を保つために、他のアプリで開かれたフィードの情報を収得
#define SYNCHRO  @"https://sandbox.feedly.com/v3/markers/reads"

//-- エントリーIDでfeedを取得
#define ENTRY @"https://sandbox.feedly.com/v3/entries/"

//-- Markers
#define MARKERS @"https://sandbox.feedly.com/v3/markers"

//-- ユーザープロファイル
#define PROFILE @"https://sandbox.feedly.com/v3/profile"

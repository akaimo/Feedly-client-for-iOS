//-- 全カテゴリと各フィードの未読数の収得
#define UNREAD_COUNT @"https://sandbox.feedly.com/v3/markers/counts"

//-- カテゴリ一覧を収得
#define CATEGORY @"https://sandbox.feedly.com/v3/categories"

//-- フィードを新しい順で収得
#define FEED @"https://sandbox.feedly.com/v3/streams/contents?streamId=user/f58dd0b1-89a5-4161-8dfd-79d0a62be44e/category/global.all&count=1"

//-- savedのフィードを収得
#define SAVED @"https://sandbox.feedly.com/v3/streams/contents?streamId=user/f58dd0b1-89a5-4161-8dfd-79d0a62be44e/tag/global.saved"

//-- キャッシュの整合性を保つために、他のアプリで開かれたフィードの情報を収得
#define SYNCHRO  @"https://sandbox.feedly.com/v3/markers/reads"

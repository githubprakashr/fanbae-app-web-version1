part of 'download_item.dart';

class DownloadItemAdapter extends TypeAdapter<DownloadItem> {
  @override
  final int typeId = 0;

  @override
  DownloadItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DownloadItem(
      id: fields[0] as int?,
      contentType: fields[1] as int?,
      channelId: fields[2] as String?,
      categoryId: fields[3] as int?,
      languageId: fields[4] as int?,
      artistId: fields[5] as int?,
      hashtagId: fields[6] as String?,
      title: fields[7] as String?,
      description: fields[8] as String?,
      portraitImg: fields[9] as String?,
      landscapeImg: fields[10] as String?,
      contentUploadType: fields[11] as String?,
      content: fields[12] as String?,
      contentSize: fields[13] as String?,
      isRent: fields[14] as int?,
      rentPrice: fields[15] as int?,
      isComment: fields[16] as int?,
      isDownload: fields[17] as int?,
      isLike: fields[18] as int?,
      totalView: fields[19] as int?,
      totalLike: fields[20] as int?,
      totalDislike: fields[21] as int?,
      playlistType: fields[22] as int?,
      isAdminAdded: fields[23] as int?,
      status: fields[24] as int?,
      createdAt: fields[25] as String?,
      updatedAt: fields[26] as String?,
      channelName: fields[27] as String?,
      channelImage: fields[28] as String?,
      userId: fields[29] as int?,
      isSubscribe: fields[30] as int?,
      categoryName: fields[31] as String?,
      artistName: fields[32] as String?,
      languageName: fields[33] as String?,
      totalComment: fields[34] as int?,
      isUserLikeDislike: fields[35] as int?,
      totalSubscriber: fields[36] as int?,
      isBuy: fields[37] as int?,
      stopTime: fields[38] as int?,
      isUserDownload: fields[39] as int?,
      securityKey: fields[40] as String?,
      securityIVKey: fields[41] as String?,
      savedDir: fields[42] as String?,
      savedFile: fields[43] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DownloadItem obj) {
    writer
      ..writeByte(44)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.contentType)
      ..writeByte(2)
      ..write(obj.channelId)
      ..writeByte(3)
      ..write(obj.categoryId)
      ..writeByte(4)
      ..write(obj.languageId)
      ..writeByte(5)
      ..write(obj.artistId)
      ..writeByte(6)
      ..write(obj.hashtagId)
      ..writeByte(7)
      ..write(obj.title)
      ..writeByte(8)
      ..write(obj.description)
      ..writeByte(9)
      ..write(obj.portraitImg)
      ..writeByte(10)
      ..write(obj.landscapeImg)
      ..writeByte(11)
      ..write(obj.contentUploadType)
      ..writeByte(12)
      ..write(obj.content)
      ..writeByte(13)
      ..write(obj.contentSize)
      ..writeByte(14)
      ..write(obj.isRent)
      ..writeByte(15)
      ..write(obj.rentPrice)
      ..writeByte(16)
      ..write(obj.isComment)
      ..writeByte(17)
      ..write(obj.isDownload)
      ..writeByte(18)
      ..write(obj.isLike)
      ..writeByte(19)
      ..write(obj.totalView)
      ..writeByte(20)
      ..write(obj.totalLike)
      ..writeByte(21)
      ..write(obj.totalDislike)
      ..writeByte(22)
      ..write(obj.playlistType)
      ..writeByte(23)
      ..write(obj.isAdminAdded)
      ..writeByte(24)
      ..write(obj.status)
      ..writeByte(25)
      ..write(obj.createdAt)
      ..writeByte(26)
      ..write(obj.updatedAt)
      ..writeByte(27)
      ..write(obj.channelName)
      ..writeByte(28)
      ..write(obj.channelImage)
      ..writeByte(29)
      ..write(obj.userId)
      ..writeByte(30)
      ..write(obj.isSubscribe)
      ..writeByte(31)
      ..write(obj.categoryName)
      ..writeByte(32)
      ..write(obj.artistName)
      ..writeByte(33)
      ..write(obj.languageName)
      ..writeByte(34)
      ..write(obj.totalComment)
      ..writeByte(35)
      ..write(obj.isUserLikeDislike)
      ..writeByte(36)
      ..write(obj.totalSubscriber)
      ..writeByte(37)
      ..write(obj.isBuy)
      ..writeByte(38)
      ..write(obj.stopTime)
      ..writeByte(39)
      ..write(obj.isUserDownload)
      ..writeByte(40)
      ..write(obj.securityKey)
      ..writeByte(41)
      ..write(obj.securityIVKey)
      ..writeByte(42)
      ..write(obj.savedDir)
      ..writeByte(43)
      ..write(obj.savedFile);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

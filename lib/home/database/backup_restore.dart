import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as s;
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:googleapis_auth/auth_io.dart';
import 'package:home_budget_app/home/database/database_util.dart';
import 'package:home_budget_app/home/database/storageClass.dart';
import 'package:home_budget_app/home/ui/utilities.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaml/yaml.dart';

const List<String> _scopes = <String>[ga.DriveApi.DriveFileScope];

class BackupUtils {
  static GDriveConfig _config;
  static final SecureStorage storage = SecureStorage();

  static Future<ga.DriveApi> getGDrive() async {
    if (null == _config) {
      debugPrint('loading config values into static property');
      final String data =
          await s.rootBundle.loadString('assets/gdriveconfig.yaml');
      final dynamic mapData = loadYaml(data);

      _config = GDriveConfig();
      _config.folderId = Utils.cast<String>(mapData['folderId']);
      _config.secretKey = Utils.cast<String>(mapData['secretKey']);
      _config.clientId = Utils.cast<String>(mapData['clientId']);
    }

    final http.Client client = await getHttpClient();
    return ga.DriveApi(client);
  }

  //Upload File
  static Future<ga.File> backupFile() async {
    final ga.DriveApi drive = await getGDrive();
    await getDatabasesPath().then((String value) async {
      print('deleting the existing files');
      final ga.FileList listOfFiles = await listOfBackUpFiles();
      if (null != listOfFiles && listOfFiles.files.isNotEmpty) {
        print('length: ' + listOfFiles.files.length.toString());
        for (final ga.File file in listOfFiles.files) {
          await deleteFileById(file.id);
        }
      }
      print('Creating backup now....');
      final String dbFilePath = value + '/' + DBUtils.DB_NAME;
      final File file = File(dbFilePath);
      final ga.File gFileMetaData = ga.File();

      gFileMetaData.parents = <String>[_config.folderId];
      gFileMetaData.name = 'Home_Budget_App_Backup.db';
      return await drive.files.create(gFileMetaData,
          uploadMedia: ga.Media(file.openRead(), file.lengthSync()));
    });
    return null;
  }

  static Future<void> restoreDBFile() async {
    final ga.FileList listOfFiles = await listOfBackUpFiles();
    if (null != listOfFiles && listOfFiles.files.isNotEmpty) {
      final String fileId = listOfFiles.files?.first?.id;
      if (null != fileId) {
        await saveFileAtDBLocation(fileId);
        print('restore is completed...');
      }
    }
  }

  static Future<ga.FileList> listOfBackUpFiles() async {
    final ga.DriveApi drive = await getGDrive();
    return await drive.files.list(
        q: "name contains 'Home_Budget_App_Backup'",
        spaces: 'drive',
        $fields: 'nextPageToken, files(createdTime,id,name)');
  }

  String getFormattedTodayDate() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy_MM_dd');
    return formatter.format(now);
  }

  static Future<File> saveFileAtDBLocation(String fileId) async {
    final http.Client client = await getHttpClient();
    final ga.DriveApi drive = ga.DriveApi(client);
    final dynamic file = await drive.files
        .get(fileId, downloadOptions: ga.DownloadOptions.FullMedia);
    final File saveFile =
        File(await getDatabasesPath() + '/' + DBUtils.DB_NAME);
    final List<int> dataStore = <int>[];
    file.stream.listen((dynamic data) {
      dataStore.insertAll(dataStore.length, Utils.cast(data));
    }, onDone: () {
      saveFile.writeAsBytes(dataStore);
      print('File saved at ${saveFile.path}');
    }, onError: (dynamic error) {
      print('Some Error' + Utils.cast(error));
    });

    return saveFile;
  }

  static Future<void> deleteFileById(String fileId) async {
    final http.Client client = await getHttpClient();
    final ga.DriveApi drive = ga.DriveApi(client);
    try {
      await drive.files.delete(fileId);
    } catch (e) {
      final ga.DetailedApiRequestError apiRequestError =
          Utils.cast<ga.DetailedApiRequestError>(e);
      if (apiRequestError.status == 404) {
        print('file not found');
      }
    }
  }

  static Future<http.Client> getHttpClient() async {
    //Get Credentials
    final Map<String, dynamic> credentials = await storage.getCredentials();
    if (credentials == null) {
      //Needs user authentication
      final AutoRefreshingAuthClient authClient = await clientViaUserConsent(
          ClientId(_config.clientId, _config.secretKey), _scopes, (String url) {
        //Open Url in Browser
        launch(url);
      });
      //Save Credentials
      await storage.saveCredentials(authClient.credentials.accessToken,
          authClient.credentials.refreshToken);
      return authClient;
    } else {
      print(credentials['expiry']);
      //Already authenticated
      final AccessCredentials newCredentials = await refreshCredentials(
          ClientId(_config.clientId, _config.secretKey),
          AccessCredentials(
              AccessToken(
                  Utils.cast<String>(credentials['type']),
                  Utils.cast<String>(credentials['data']),
                  DateTime.tryParse(Utils.cast<String>(credentials['expiry']))),
              Utils.cast<String>(credentials['refreshToken']),
              _scopes),
          http.Client());

      return authenticatedClient(http.Client(), newCredentials);
    }
  }
}

class GDriveConfig {
  String clientId;
  String secretKey;
  String folderId;
}

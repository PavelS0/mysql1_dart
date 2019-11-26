enum ServerVersion {
  MariaDB,
  Mysql
}

class ServerPar {
  final ServerVersion server;
  final int protocolVersion;
  final String serverVersion;
  final int threadId;
  final List<int> scrambleBuffer;
  final int serverCapabilities;
  final int serverLanguage;
  final int serverStatus;
  final int scrambleLength;
  final String pluginName;
  bool useCompression;
  bool useSSL;
  ServerPar(this.protocolVersion, this.serverVersion, this.threadId, this.scrambleBuffer, 
  this.serverCapabilities, this.serverLanguage, this.serverStatus, this.scrambleLength, 
  this.pluginName, this.useCompression, this.useSSL) : 
    server = serverVersion.contains("MariaDB") ? ServerVersion.MariaDB :  ServerVersion.Mysql {
  }
}
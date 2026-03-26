{
  config,
  lib,
  ...
}: {
  config = {
    services.gitea = {
      enable = true;
      database.type = "sqlite3";
      #settings.service.DISABLE_REGISTRATION = true;
    };
  };
}

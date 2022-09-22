$mosquitto_path = "C:\Program Files\mosquitto"
Set-Item Env:Path "$Env:Path;$mosquitto_path;"
mosquitto_sub -d -t "topic/#"
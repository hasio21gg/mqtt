import asyncio
import uuid
from bleak import BleakScanner
from bleak import BleakClient
from bleak import BleakError

#device_name = "FIVE_STACK"
device_name = "C0-1C-4D-44-5E-C7"
#[Characteristic] 6e400003-b5a3-f393-e0a9-e50e24dcca9e (Handle: 20): 
# (notify), Value: None
#read_UUID = uuid.UUID("6e400003-b5a3-f393-e0a9-e50e24dcca9e")
read_UUID = uuid.UUID("ecce492b-db69-1801-84fb-001c4d4c1ecc")

async def ble_scan():
    devices = await BleakScanner.discover()
    print(devices)
    idx = list(filter(lambda x: x.name == device_name, devices))

    # 検出デバイスの表示
    #for d in devices:
    #    print(d)

    global ADDRESS
    ADDRESS = idx[0].address
    print("find device " + str(idx[0].name))

async def connect_read():
    global ADDRESS

    async with BleakClient(ADDRESS,use_cached=False) as client:
        def callback(sender, data):
            print(f"Received: {data}")

            data_str = data.decode()
            print("decode ->"+data_str)
        
        print("..receive message")
        while True:
            await client.start_notify(read_UUID, callback)          

if __name__ == "__main__":
    asyncio.run(ble_scan())
    asyncio.run(connect_read())
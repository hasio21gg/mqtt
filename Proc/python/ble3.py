import asyncio
import logging
from bleak import BleakScanner

async def main(timeout=5.0):
    devices=dict()
    eol=""
    for d in await BleakScanner.discover(timeout=timeout, service_uuids=[]):
        if d.name and (d.name != 'Unknown'):
            # device has attributes :'address',  'metadata',  'name',  'rssi' ,  'details'
            print(f"Found {eol}{d.name=},\n\t{d.address=},\n\t{d.rssi=},\n\t{d.metadata=},\n\t{d.details=}")
            devices[d.address]  =  d
            eol="\n"
    return devices

asyncio.run(main())
#ble_devices=await main(10) #jupyterでは既にloopが走っているので、awaitできる。というか、asyncio.runは使えない。
print("Found devices:", ble_devices)
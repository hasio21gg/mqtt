import asyncio
from bleak import BleakScanner

MANUFACTURER_CODE = 0xFFFF

async def main():
    devices = await BleakScanner.discover()
    for d in devices:
        #print(d)
        #if MANUFACTURER_CODE in d.metadata.get('manufacturer_data', {}):
        #    print("====================")
        #else:
        #    print("-----------------------")
        print(f'[%s][%s][%s][%s]' % (d.address, d.name, d.metadata, d.rssi))

asyncio.run(main())

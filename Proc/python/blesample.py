import asyncio

from bleak import BleakClient

temperatureUUID = "45366e80-cf3a-11e1-9ab4-0002a5d5c51b"
ecgUUID = "46366e80-cf3a-11e1-9ab4-0002a5d5c51b"

notify_uuid = "0000{0:x}-0000-1000-8000-00805f9b34fb".format(0xFFE1)


def callback(sender, data):
    print(sender, data)


async def connect_to_device(address):
    print("starting", address, "loop")
    async with BleakClient(address, timeout=5.0) as client:

        print("connect to", address)
        try:
            await client.start_notify(notify_uuid, callback)
            await asyncio.sleep(10.0)
            await client.stop_notify(notify_uuid)
        except Exception as e:
            print(e)

    print("disconnect from", address)


def main():
    return asyncio.gather(connect_to_device("ECCE492B-DB69-1801-84FB-001C4D4C1ECC"))


if __name__ == "__main__":
    asyncio.run(main())

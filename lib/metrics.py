from influxdb import InfluxDBClient

class MetricsWriter:
    def __init__(
        self,
        host="127.0.0.1",
        port=8086,
        username="admin",
        password="admin123",
        database="netops",
    ):
        self.client = InfluxDBClient(
            host=host,
            port=port,
            username=username,
            password=password,
            database=database,
        )

    def write(self, measurement: str, tags: dict, fields: dict):
        point = [
            {
                "measurement": measurement,
                "tags": tags,
                "fields": fields,
            }
        ]
        return self.client.write_points(point)

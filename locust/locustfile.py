from locust import HttpUser, task, constant


class WineSearchUser(HttpUser):
    # Target из конфига (ssl: false => http://)
    host = "http://62.84.126.52:8000"

    # Pandora: ops=100, instances=50 => 100 RPS / 50 юзеров = 2 запроса/сек на одного юзера
    # Пауза между запросами = 0.5 сек. (Locust меряет нагрузку пользователями, а не RPS)
    wait_time = constant(0.5)

    @task
    def search_wines(self):
        self.client.post(
            "/search/wines",
            json={"query": "красное сухое", "priceMin": 500, "priceMax": 20000},
            headers={
                "Accept": "application/json"
            },  # Content-Type ставится автоматически из json=
            name="POST /search/wines",  # Для группировки статистики в UI
        )

# Postgresql master-slave 教學

* [Youtube Tutorial - Postgresql 教學 master-slave](https://youtu.be/zxxzcpvCa6o)

## 介紹 master-slave 主從複寫

簡易架構圖

![alt tag](https://github.com/twtrubiks/postgresql-note/blob/main/pg-master-slave/image.png?raw=true)

Master 可讀寫, Slave 只能讀.

這邊為了簡單體驗一下, 只實現藍色的部份,

使用一台電腦模擬, 所以使用 port 模擬兩台電腦.

```text
Master ip 179.19.0.101   port 5433

Slave  ip 179.19.0.102   port 5434
```

Postgresql 會自動幫你把 Master 的東西寫到 Slave.

## 教學

使用 Postgresql 13 並透過 docker 來當作範例, 並體驗一下這是什麼東西

也建議大家可以上網查一下 PostgreSQL Write-Ahead Logging (WAL):sunglasses:

基本上它就是會紀錄 PostgreSQL 中的新增修改刪除.

### master

[docker-compose.yml](docker-compose.yml)

```yml
version: '3.5'
services:

  master:
      restart: always
      image: postgres:13
      container_name: master
      ports:
        - "5433:5432"
      environment:
        - POSTGRES_PASSWORD=postgres
        - POSTGRES_USER=postgres
        - POSTGRES_DB=postgres
      volumes:
        - ./data/psql/master:/var/lib/postgresql/data
      networks:
        mynetwork:
          ipv4_address: 179.19.0.101

  # slave:
  #     restart: always
  #     image: postgres:13
  #     container_name: slave
  #     ports:
  #       - "5434:5432"
  #     environment:
  #       - POSTGRES_PASSWORD=postgres
  #       - POSTGRES_USER=postgres
  #       - POSTGRES_DB=postgres
  #     volumes:
  #       - ./data/psql/slave:/var/lib/postgresql/data
  #       - ./data/psql/repl:/var/lib/postgresql/repl
  #     networks:
  #       mynetwork:
  #         ipv4_address: 179.19.0.102

networks:
  mynetwork:
    driver: bridge
    ipam:
      config:
      - subnet: 179.19.0.0/24
```

先把 slave 的部份註解起來, 只執行 master,

`docker-compose up -d`

接著執行以下指令

```cmd
# 進入 master container
docker exec -it master bash

# 連接 postgres
psql -U postgres

# 建立 user rules
CREATE ROLE repuser WITH LOGIN REPLICATION PASSWORD '666666';

# 如果想要查看規則
\du
```

(為了方便直接從本機修改容器內資料, 執行 `sudo chmod -R 777 data`)

修改 master 中的 `pg_hba.conf`

```cmd
# 切換到 master 路徑
cd ./data/psql/master

# 增加 rules (填入 slave 的 ip )
echo "host replication repuser 179.19.0.102/24 md5" >> pg_hba.conf
```

修改 master 中的 `postgresql.conf`

這邊只列出要修改的內容

```conf
archive_mode = on
archive_command = '/bin/date'
max_wal_senders = 10
wal_keep_size = 16
synchronous_standby_names = '*'
```

詳細參數說明可以再自行 google :smile:

重啟, 確保設定生效 `docker-compose restart`

### slave

將 [docker-compose.yml](docker-compose.yml) slave 註解的地方取消,

然後再執行 `docker-compose up -d`

(為了方便直接從本機修改容器內資料, 執行 `sudo chmod -R 777 data`)

接著執行以下指令,

```cmd
# 進入 slave container
docker exec -it slave bash

# 透過 pg_basebackup 指令,
# 將資料從 master 備份到 repl folder
pg_basebackup -R -D /var/lib/postgresql/repl -Fp -Xs -v -P -h 179.19.0.101 -p 5432 -U repuser
```

![alt tag](https://i.imgur.com/vP4bH41.png)

關於 pg_basebackup 說明,

可參考 [https://docs.postgresql.tw/reference/client-applications/pg_basebackup](https://docs.postgresql.tw/reference/client-applications/pg_basebackup)

關閉容器 `docker-compose down`,

重建 slave container,

```cmd
# 切換目錄資料夾
cd ./data/psql/

# 移除 slave 資料夾
sudo rm -rf slave

# 修改資料夾名稱, repl -> slave
sudo mv repl slave

# 查看 postgresql.auto.conf (會看到連線到 master 的資料)
cat slave/postgresql.auto.conf
```

接著修改 [docker-compose.yml](docker-compose.yml),

volume 只使用 slave,

```yml
......
    slave:
      restart: always
      image: postgres:13
      container_name: slave
      ports:
        - "5434:5432"
      environment:
        - POSTGRES_PASSWORD=postgres
        - POSTGRES_USER=postgres
        - POSTGRES_DB=postgres
      volumes:
        - ./data/psql/slave:/var/lib/postgresql/data
        # - ./data/psql/repl:/var/lib/postgresql/repl
......

```

再啟動 `docker-compose up`, 基本上這樣就完成了:smiley:

可以使用該指令確認

```cmd
ps -aux | grep postgres
```

![alt tag](https://i.imgur.com/UP9ZyYw.png)

## 驗證 master-slave

如果你不喜歡使用指令,

也可以用 [docker-pgadmin4-tutorial](https://github.com/twtrubiks/docker-pgadmin4-tutorial) 來測試, 結果都是一樣的.

### master

進入 master container

```cmd
docker exec -it master bash
psql -U postgres

-- 查看 replication information
select * from pg_stat_replication;
```

接著繼續建立測試 db

```cmd
CREATE DATABASE test;

-- 切換 db
\c test

-- 建立 table
CREATE TABLE test (
  id integer not null,
  value character varying,
  PRIMARY KEY (id)
);


-- 查看 table
\dt

-- 建立測試資料
insert into test select generate_series(1,20),random();

-- 查看資料
select * from test;
```

### slave

如果你設定正確, 這邊應該會看到和 master 一模一樣的東西,

因為全部資料會自動被同步過來.

進入 slave container

```cmd
docker exec -it slave bash
psql -U postgres

-- 查看 db
\d

-- 查看 table
\c test

-- 查看資料
select * from test;

```

注意:exclamation: slave 是 read-only, 所以這邊是無法新增修改刪除.

## 其他

如果你想要更簡單一鍵就設定好的, 可以使用這個 [https://hub.docker.com/r/bitnami/postgresql/](https://hub.docker.com/r/bitnami/postgresql/)

## Reference

* [https://programmer.group/docker-configures-the-master-slave-environment-of-postgresql13.html](https://programmer.group/docker-configures-the-master-slave-environment-of-postgresql13.html)
* [主從複寫](https://github.com/donnemartin/system-design-primer/blob/master/README-zh-TW.md#%E4%B8%BB%E5%BE%9E%E8%A4%87%E5%AF%AB)
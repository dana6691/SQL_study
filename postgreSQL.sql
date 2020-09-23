'''
- Create databases and schemas to organize our data
- Create tables and load CSV data into them
- Manage Postgres users in a secured way by assigning the right privileges
- Avoid SQL injections
'''
/*******************************************************************/
/*import library, connect to the database, close a connection*/
import psycopg2
conn = psycopg2.connect("dbname=dq user=dq")
conn.close()  
/*create cursor object, execute the query, fetch all, close the connection*/
import psycopg2
conn = psycopg2.connect("dbname=dq user=dq")
cur = conn.cursor()
cur.execute("SELECT * FROM users;")
users = cur.fetchall()
conn.close()
/*create table*/
cur.execute("CREATE TABLE users(id integer PRIMARY KEY, email text, name text, address text);")
/*transaction committed*/
-- commit: change on the database is effective only if you commit them to prevent query to execute patially
query_string = """
    CREATE TABLE users(
        id integer PRIMARY KEY, 
        email text,
        name text,
        address text
    );
"""
cur = conn.cursor()
cur.execute(query_string)
conn.commit()
conn.close()
/*Before and After commit by cur1*/
import psycopg2
conn1 = psycopg2.connect("dbname=dq user=dq")
cur1 = conn1.cursor()
cur1.execute("INSERT INTO users VALUES (%s, %s, %s, %s);", (1, 'alice@dataquest.io', 'Alice', '99 Fake Street'))
conn2 = psycopg2.connect("dbname=dq user=dq")
cur2 = conn2.cursor()
# add your code here
cur1.execute("SELECT * FROM users;")
view1_before = cur1.fetchall()
cur2.execute("SELECT * FROM users;")
view2_before = cur2.fetchall()
conn1.commit()
cur2.execute("SELECT * FROM users;")
view2_after = cur2.fetchall()
/*Insert queries*/
-- transasction block: All the queries issued between two commits
import psycopg2
conn = psycopg2.connect("dbname=dq user=dq")
cur = conn.cursor()
cur.execute("INSERT INTO users VALUES(%s, %s, %s, %s);",
            (2, 'alice@dataquest.io', 'Alice', '99 Fake Street'))
conn.commit()
conn.close()
/*Insert should be a sequence(either list or tuples)*/
'''
cur.execute("INSERT INTO foo VALUES (%s)", ("bar",)) # correct
cur.execute("INSERT INTO foo VALUES (%s)", ["bar"])  # correct
cur.execute("INSERT INTO numbers VALUES (%s)", (10,))   # correct
'''
/*Load csv file*/
import psycopg2
import csv
conn = psycopg2.connect("dbname=dq user=dq")
cur = conn.cursor()
with open('user_accounts.csv') as file:
    next(file) --skip csv header
    reader = csv.reader(file)
    for row in reader:
        cur.execute("INSERT INTO users VALUES(%s,%s,%s,%s);",row)
conn.commit()
conn.close()
/*******************************************************************/
-- DataError: integer out of range --> integer value is too larage
/*Execute zero row, print description attribute*/
/*data type*/
cur.execute("SELECT * FROM ign_reviews LIMIT 0;")
print(cur.description)
-- only focus on 'name','type_code','internal_size in description'
/*find datatype of row 25 and 700*/
cur.execute("SELECT typname FROM pg_catalog.pg_type WHERE oid=25;")
type_name_25 = cur.fetchone()[0]
print(type_name_25)
cur.execute("SELECT typname FROM pg_catalog.pg_type WHERE oid=700;")
type_name_700 = cur.fetchone()[0]
print(type_name_700)
/*change score column datatype to decimal*/
cur.execute("""
ALTER TABLE ign_reviews
ALTER COLUMN score TYPE DECIMAL(3,1);
""")
conn.commit()
conn.close()
/*maximum length word*/
import csv
with open('ign.csv', 'r') as f:
    next(f) # skip the row containing column headers
    reader = csv.reader(f)
    # create a set to contain all score phrases
    unique_words_in_score_phrase = set()
    for row in reader:
        # add the score phrase from this row to the set
        score_phrase = row[1]
        unique_words_in_score_phrase.add(score_phrase)
max_len =0
for score in unique_words_in_score_phrase:
    max_len = max(max_len, len(score))
print(max_len)
/*******************************************************************/
-- char(n): padded white space
-- varchar(n): no padded white space
/*******************************************************************/
/*change the datatype to a enumerated datatype*/
cur.execute("""
    CREATE TYPE evaluation_enum AS ENUM (
    'Great',       'Mediocre', 'Bad', 
    'Good',        'Awful',    'Okay', 
    'Masterpiece', 'Amazing',  'Unbearable', 
    'Disaster',    'Painful');
""")
cur.execute("""
    ALTER TABLE ign_reviews 
    ALTER COLUMN score_phrase TYPE evaluation_enum 
    USING score_phrase::evaluation_enum;
""")
conn.commit()
conn.close()
/*change the datatype to boolean*/
cur.execute("""
    ALTER TABLE ign_reviews 
    ALTER COLUMN editors_choice TYPE boolean
    USING editors_choice::boolean;
""")
conn.commit()
conn.close()
/*add column, drop column*/
cur.execute("ALTER TABLE ign_reviews ADD COLUMN release_date date;")
cur.execute("ALTER TABLE ign_reviews DROP COLUMN release_year;")
cur.execute("ALTER TABLE ign_reviews DROP COLUMN release_month;")
/*add date, read csv file*/
import datetime
import csv
with open('ign.csv', 'r') as file:
    next(file) # skip csv header (first row with column titles)
    reader = csv.reader(file)
    for row in reader:
        year = int(row[8]) # the elements in row are strings so we need to convert to int
        month = int(row[9])
        day = int(row[10])
        date = datetime.date(year, month, day)
        row = row[:-3]
        row.append(date)
        cur.execute("INSERT INTO ign_reviews VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s);", row)
# commit the changes and close the connection
conn.commit()
conn.close()
/*insert with dictionary*/
row_values = { 
    'identifier': 1, 
    'mail': 'adam.smith@dataquest.io',
    'name': 'Adam Smith', 
    'address': '42 Fake Street'
}
import psycopg2
conn = psycopg2.connect("dbname=dq user=dq")
cur = conn.cursor()
cur.execute("INSERT INTO users VALUES(%(identifier)s, %(mail)s, %(name)s, %(address)s);",row_values)
conn.commit()
conn.close()
/*******************************************************************************/
/*function for getting email*/
def get_email(name):
    import psycopg2
    conn = psycopg2.connect("dbname=dq user=dq")
    cur = conn.cursor()
    query_string = "SELECT email FROM users WHERE name = '" + name + "';"
    cur.execute(query_string)
    res = cur.fetchall()
    conn.close()
    return res
/*name Joseph Kirby or anyone else*/
all_emails = get_email("Joseph Kirby' OR 1 = 1; --")
/*name + address*/
name = "Larry Cain' UNION SELECT address FROM users WHERE name = 'Larry Cain"
address_and_email = get_email(name)
print(address_and_email)
/*function(2) - name format method change*/
def get_email_fixed(name):
   import psycopg2
   conn = psycopg2.connect("dbname=dq user=dq")
   cur = conn.cursor()
   # fix the line below
   cur.execute("SELECT email FROM users WHERE name = %s",(name,))
   res = cur.fetchall()
   conn.close()
   return res
/*direct inject data(without commit)*/
user = (10003, 'alice@dataquest.io', 'Alice', '102, Fake Street')
cur.execute("""
    PREPARE insert_user(integer, text, text, text) AS
    INSERT INTO users VALUES ($1, $2, $3, $4);
""")
cur.execute("""
    EXECUTE insert_user(%s, %s, %s, %s);
""", user)

/*******************************************************************************/
-- SUPERUSER:
-- CREATEDB: allow user to create database
-- NOCREATEDB: not allow to create database
-- REVOKE: those privileges are to be revoked
    -- REVOKE DELETE/DROP/UPDATE/SELECT/ALL ON table FROM user_name;
    -- REVOKE CONNECT ON DATABASE my_database FROM readonly;
    -- REVOKE ALL ON DATABASE my_database FROM public;
-- GRANT: grant privileges
    -- DELETE/DROP/UPDATE/SELECT/ALL ON table TO user_name;
-- create/alter user
    -- CREATE/ALTER USER username WITH + 
-- create database with owner
    -- CREATE DATABASE my_database OWNER postgres
-- schemas: folders for organizing the tables within a single database
/*******************************************************************************/
/*connect database to user*/
conn = psycopg2.connect(dbname='dq', user='postgres', password='abc123')
print(conn)    
/*connect database to user & create superuser*/
conn = psycopg2.connect(dbname='dq', user='postgres', password='abs123')
cur = conn.cursor()
cur.execute("CREATE USER data_viewer WITH SUPERUSER PASSWORD 'secret';")
/*print each row in separate line - from user table*/
cur.execute("SELECT * FROM pg_user;")
users = cur.fetchall()
for user in users:
    print(user)
conn.close()
/*REVOKE/GRANT*/
cur.execute("REVOKE ALL ON users FROM data_viewer;")
cur.execute("GRANT SELECT ON users TO data_viewer;")
conn.commit()
conn.close()
/*find grantor, grantee, privilege_type*/
cur.execute("SELECT grantor,grantee,privilege_type FROM information_schema.table_privileges WHERE table_name = 'users';")
privileges = cur.fetchall()
for i in privileges:
    print(i)
conn.close()
/*NON-superuser -- cannot insert anymore*/
cur.execute("ALTER USER data_viewer WITH NOSUPERUSER;")
cur.execute("INSERT INTO users VALUES (%s, %s, %s, %s);", 
            (10002, 'alice@dataquest.io', 'Alice', '100, Fake St'))
/*
create group
revoke all for group
grant select to group
assign data_viewer user to group*/
cur.execute("CREATE GROUP readonly NOLOGIN;")
cur.execute("REVOKE ALL ON users FROM readonly;")
cur.execute("GRANT SELECT, INSERT, DELETE ON users TO readonly;")
cur.execute("GRANT readonly TO data_viewer;")
conn.commit()
conn.close()            
/*Instant commit for create database*/
'''if OWNER is not specified, then the current user will be the owner. 
    The owner is always a superuser.
'''
conn.autocommit = True
cur = conn.cursor()
cur.execute("CREATE DATABASE my_database OWNER postgres;")
conn.autocommit = False
/*REVOKE all privileges from public group*/
/*REVOKE connection privileges from readonly group*/
'''
All users belong to group named PUBLIC
when we created database, all PUBLIC users are assigned
'''
cur.execute("REVOKE ALL ON DATABASE my_database FROM public;")
cur.execute("REVOKE CONNECT ON DATABASE my_database FROM readonly;")
/*create SCHEMA*/
'''
As default, all created table is in the 'public' schema
'''
cur.execute("CREATE SCHEMA my_schema;")
/*******************************************************************************/
-- explore the HUD tables using internal Postgres tables 
-- to give us a detailed description about the contents of the database.

-- Postgres to work on a database from the Department of Housing and Urban development (HUD)
-- how to analyze queries and understand how to make them run much faster by using indexes
-- how to maintain the database cleaned so that we don't run out of disk space and our query performance remains high
/*******************************************************************************/
-- import psycopg2 library
-- Connect to the hud database with the user & password
-- Close the connection
-- Select
-- Obtain all result
-- print the name of each table
import psycopg2
conn = psycopg2.connect("dbname=hud user=hud_admin password=hud_pwd")
cur = conn.cursor()
cur.execute("""SELECT tablename 
FROM pg_catalog.pg_tables
ORDER BY tablename;""")
table_names = cur.fetchall()
print(len(table_names))
for name in table_names:
    print(name)
/*******************************************************************/
-- How do we know which tables are internal and which tables are user created?
-- internal tables
-- 1) pg_catalog for the system catalog tables;
-- 2) information_schema for the information schema tables;
-- 3) public the default schema for user created tables.
/*******************************************************************/
 -- SELECT query cannot be a quoted string. Therefore, AsIs keeps it as a valid SQL representation of non-string

from psycopg2.extensions import AsIs
col_descriptions = {}
for table_name in table_names:
    cur.execute("SELECT * FROM %s LIMIT 0;", (AsIs(table_name),))
    col_descriptions[table_name] = cur.description
conn.close()
/*******************************************************************/
-- store descriptions in dictionary;name, types, display_size, precision, scale
cur.execute("SELECT oid, typname FROM pg_catalog.pg_type;")
type_mappings = {int(oid): typename for oid, typename in cur.fetchall()}
print(type_mappings[1082])
/*******************************************************************/
-- SQLite was not built for multiple connections. 
-- SQLite only allows a single process to write to the DATABASE
Postgres is a much more robust engine that is implemented as a server rather than a single file
accepts connections from clients who can run queries like a SELECT, INSERT, or any other type of SQL query making the data accessible to a wide range of people.


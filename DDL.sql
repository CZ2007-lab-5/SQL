if OBJECT_ID('PRICE_HISTORY') is not null  
  drop table PRICE_HISTORY;
if OBJECT_ID('PRODUCT_IN_ORDERS') is not null  
  drop table PRODUCT_IN_ORDERS;
if OBJECT_ID('PRODUCT_IN_SHOPS') is not null  
  drop table PRODUCT_IN_SHOPS;
if OBJECT_ID('FEEDBACK') is not null  
  drop table FEEDBACK;
if OBJECT_ID('PRODUCTS') is not null  
  drop table PRODUCTS;

if OBJECT_ID('COMPLAINTS_ON_SHOPS') is not null  
  drop table COMPLAINTS_ON_SHOPS;
if OBJECT_ID('COMPLAINTS_ON_ORDERS') is not null  
  drop table COMPLAINTS_ON_ORDERS;
if OBJECT_ID('COMPLAINTS') is not null  
  drop table COMPLAINTS;

if OBJECT_ID('EMPLOYEES') is not null  
  drop table EMPLOYEES;
 
if OBJECT_ID('ORDERS') is not null  
  drop table ORDERS;

if OBJECT_ID('USERS') is not null  
  drop table USERS;

if OBJECT_ID('SHOPS') is not null  
  drop table SHOPS;


create table SHOPS (
  SID varchar(8),
  SName varchar(70) not null,
  primary key (SID)
);

create table EMPLOYEES (
  ID varchar(8),
  Name varchar(70) not null,
  Salary numeric(12, 2) not null check(Salary > 0),
  primary key (ID)
);

create table USERS (
  UID varchar(8),
  UName varchar(70) not null,
  primary key (UID)
);

create table COMPLAINTS (
  ID varchar(8),
  UID varchar(8),
  EID varchar(8),
  Text varchar(300) not null,
  Filed_date_time datetime not null,
  Handled_date_time datetime,
  Addressed_date_time datetime,
  Status varchar(20) check (Status in ('pending', 'being handled', 'addressed')),
  primary key (ID),
  foreign key (UID) references USERS(UID) on update cascade on delete set null,
  foreign key (EID) references EMPLOYEES(ID) on update cascade on delete set null
);

create table COMPLAINTS_ON_SHOPS (
  ID varchar(8),
  SID varchar(8),
  primary key (ID),
  foreign key (ID) references COMPLAINTS(ID) on update cascade on delete cascade,
  -- better to follow COMPLAINTS_ON_SHOPS
  -- foreign key (SID) references SHOPS(SID) -- on update cascade on delete set null
);

create table ORDERS (
  OID varchar(8),
  UID varchar(8),
  Date_time datetime not null,
  Shipping_address varchar(100) not null,
  Shipping_cost numeric(12, 2),
  primary key (OID),
  foreign key (UID) references USERS(UID) on update cascade on delete set null
);

create table COMPLAINTS_ON_ORDERS (
  ID varchar(8),
  OID varchar(8),
  primary key (ID),
  foreign key (ID) references COMPLAINTS(ID) on update cascade on delete cascade,
  -- maybe add trigger or check in COMPLAINTS
  -- foreign key (OID) references ORDERS(OID) on update cascade on delete set null
);

create table PRODUCTS (
  PID varchar(8),
  PName varchar(70) not null,
  Maker varchar(70) not null,
  Category varchar(70) not null,
  primary key (PID)
);

create table FEEDBACK (
  UID varchar(8),
  PID varchar(8),
  Rating int not null check(Rating in (1, 2, 3, 4, 5)),
  Date_time datetime not null,
  Comment varchar(300),
  primary key (UID, PID),
  foreign key (UID) references USERS(UID) on update cascade on delete cascade,
  foreign key (PID) references PRODUCTS(PID) on update cascade on delete cascade
);

create table PRODUCT_IN_SHOPS (
  PID varchar(8),
  SID varchar(8),
  SPrice numeric(12, 2) not null check(SPrice > 0),
  SQuantity int not null check(SQuantity >= 0),
  primary key (PID, SID),
  foreign key (PID) references PRODUCTS(PID) on update cascade on delete cascade,
  foreign key (SID) references SHOPS(SID) on update cascade on delete cascade
);

create table PRODUCT_IN_ORDERS (
  PID varchar(8),
  OID varchar(8),
  SID varchar(8),
  OPrice numeric(12, 2) not null check(OPrice > 0),
  OQuantity int not null check(OQuantity >= 0),
  Delivery_date date not null,
  Status varchar(8) check(Status in ('being processed', 'shipped', 'returned', 'delivered')),
  primary key (PID, OID, SID),
  foreign key (PID) references PRODUCTS(PID) on update cascade on delete cascade,
  foreign key (OID) references ORDERS(OID) on update cascade on delete cascade,
  -- foreign key (SID) references SHOPS(SID) on update cascade on delete cascade
);

create table PRICE_HISTORY (
  PID varchar(8),
  SID varchar(8),
  Start_date date,
  End_date date not null, -- null if End_date is today?
  Price numeric(12, 2) not null check(Price > 0),
  primary key (PID, SID, Start_date),
  foreign key (PID, SID) references PRODUCT_IN_SHOPS(PID, SID) on update cascade on delete cascade
);
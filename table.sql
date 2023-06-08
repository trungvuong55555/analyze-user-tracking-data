create table users (
    user_id int primary key,
    name VARCHAR ( 500 ) not null,
    email VARCHAR ( 255 ) not null,
    address Text not null,
    phone_number VARCHAR ( 50 ) not null,
    age int not null,
    weight int not null,
    high int not null
);

create table tracking(
    id serial primary key,
    user_id int not null,
    lat int not null,
    lon int not null,
    millisecond bigint,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);
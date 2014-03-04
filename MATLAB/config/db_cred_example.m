function [ host, port, username, password ] = db_cred_example( schema )
%DB_CRED Abstracting the storage of database credentials
%   Abstracting the storage of database connection information so that
%   files can be committed to version control system.
%
%   This file is intended to be copied to db-config.m and the function
%   renamed to db-config. Then fill it out with connection information
%   relevant to your database.

%%
% Add MySQL driver to classpath
javaclasspath('lib/mysql-connector-java-5.1.29-bin.jar');

%%
% Configure database credentials
host = 'DB_HOST';
port = 3306;
username = 'DB_USERNAME';
password = 'DB_PASSWORD';
end


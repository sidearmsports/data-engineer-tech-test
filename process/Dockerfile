FROM python:3.9.16-slim
RUN apt-get update && apt-get install -y \
    software-properties-common \
    curl \
    nano
# RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
# RUN curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list | tee /etc/apt/sources.list.d/msprod.list
# RUN apt-get update && ACCEPT_EULA=Y apt-get install -y mssql-tools unixodbc-dev    

RUN curl https://dl.min.io/client/mc/release/linux-amd64/mc \
    --create-dirs -o /usr/local/bin/mc &&  \
    chmod +x /usr/local/bin/mc 

RUN pip install pandas mssql minio boto3 mssql-cli

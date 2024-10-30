FROM ubuntu:22.04                                                                                                                                       
WORKDIR /app/
COPY . .

RUN apt update -y && apt install -y curl sudo wget unzip
RUN chmod +x install.sh && ./install.sh

CMD ["/app/goedge/edge-admin/bin/edge-admin", "start"]

FROM openjdk:8-alpine
MAINTAINER Benjamin Ricaud <benjamin.ricaud@eviacybernetics.com>


# Install tools
RUN apk update && \
	apk add wget unzip git bash curl ca-certificates dumb-init && \
	update-ca-certificates

# Install the server
RUN wget -O /gremlin.zip https://mirrors.ocf.berkeley.edu/apache/tinkerpop/3.4.6/apache-tinkerpop-gremlin-server-3.4.6-bin.zip && \
	unzip /gremlin.zip -d /gremlin && \
	rm /gremlin.zip
WORKDIR /gremlin/apache-tinkerpop-gremlin-server-3.4.6

# Place where the graph is saved, see gremlin-graph.properties
RUN mkdir /graph_file

# Configure gremlin for python
RUN bin/gremlin-server.sh install org.apache.tinkerpop gremlin-python 3.4.6
RUN bin/gremlin-server.sh install org.apache.tinkerpop neo4j-gremlin 3.4.6

EXPOSE 8182

# Copy the configuration files
COPY files .

# Use the dumb-init init system to correctly forward shutdown signals to gremlin-server
ENTRYPOINT ["/usr/bin/dumb-init", "--rewrite", "15:2",  "--"]

# Launch
RUN chmod 700 startup_commands.sh
CMD ["./startup_commands.sh"]

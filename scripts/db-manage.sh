#!/bin/bash
# Simple database management script

DB_CONTAINER="trossapp-postgres"

case "${1:-help}" in
    "setup")
        echo "🚀 Setting up database..."
        docker-compose up -d postgres
        sleep 5
        echo "✅ Database ready"
        ;;
    "start")
        echo "� Starting database..."
        docker-compose up -d postgres
        ;;
    "stop")
        echo "🛑 Stopping database..."
        docker-compose stop postgres
        ;;
    "status")
        if docker ps | grep $DB_CONTAINER >/dev/null; then
            echo "✅ Database running"
        else
            echo "❌ Database not running"
        fi
        ;;
    "shell")
        docker exec -it $DB_CONTAINER psql -U postgres -d trossapp_dev
        ;;
    *)
        echo "Usage: $0 {setup|start|stop|status|shell}"
        ;;
esac
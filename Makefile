migration:
	@read  -p "Enter migration name: " migration_name; \
		migrate create -ext sql -dir migrations $$migration_name

migrate:
	migrate -source file://migrations -database \
		 "postgresql://myuser:mypassword@localhost:5432/mydb?sslmode=disable" up

rollback:
	migrate -source file://migrations -database \
		 "postgresql://myuser:mypassword@localhost:5432/mydb?sslmode=disable" down

drop:
	migrate -source file://migrations -database \
		 "postgresql://myuser:mypassword@localhost:5432/mydb?sslmode=disable" drop

gen:
	sqlc generate

push:
	sqlc push

verify:
	sqlc verify

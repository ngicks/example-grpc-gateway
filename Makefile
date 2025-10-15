.PHONY: help
help: ## Display this help screen
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: install-tools
install-tools: ## Install required tools
	@echo "Installing buf..."
	@go install github.com/bufbuild/buf/cmd/buf@latest
	@echo "Installing protoc-gen-go..."
	@go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
	@echo "Installing protoc-gen-go-grpc..."
	@go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
	@echo "Installing protoc-gen-grpc-gateway..."
	@go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@latest
	@echo "Installing protoc-gen-openapiv2..."
	@go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@latest
	@echo "Tools installed successfully!"

.PHONY: generate
generate: ## Generate Go code from proto files
	@echo "Generating Go code from proto files..."
	@buf generate
	@echo "Code generation completed!"

.PHONY: lint
lint: ## Lint proto files
	@echo "Linting proto files..."
	@buf lint
	@echo "Linting completed!"

.PHONY: breaking
breaking: ## Check for breaking changes
	@echo "Checking for breaking changes..."
	@buf breaking --against '.git#branch=main'
	@echo "Breaking change check completed!"

.PHONY: clean
clean: ## Clean generated files
	@echo "Cleaning generated files..."
	@rm -rf gen/
	@echo "Cleanup completed!"

.PHONY: build
build: generate ## Build the project (generates code first)
	@echo "Building Go modules..."
	@go mod tidy
	@go build ./...
	@echo "Build completed!"

.PHONY: test
test: generate ## Run tests
	@echo "Running tests..."
	@go test -v ./...
	@echo "Tests completed!"

.PHONY: deps
deps: ## Update buf dependencies
	@echo "Updating buf dependencies..."
	@buf dep update
	@echo "Dependencies updated!"

.PHONY: all
all: deps lint generate build test ## Run all steps
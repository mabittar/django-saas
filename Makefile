#################################################
#### Automatic Pythonic Developer Environment ####
#################################################
##
## If you don't really know what to do, run `make help`.
## If you don't have make installed,
## To be used on Linux system
## Make sure you have `pyenv` installed beforehand
##
## https://github.com/pyenv/pyenv

ifneq ($(shell uname -s), Linux)
@echo "Must be used on Linux environment"
exit
else
PYENV_FLAGS = CFLAGS="$(shell pkg-config --cflags libffi ncurses readline)" \
		LDFLAGS="$(shell pkg-config --libs libffi ncurses readline)" \
		CC="$(firstword $(wildcard $(shell brew --prefix gcc)/bin/gcc-*))"
endif

## Colors Config
COLOR_ORANGE = \033[33m
COLOR_BLUE = \033[34m
COLOR_RED = \033[31m
COLOR_GREEN = \033[32m
COLOR_RESET = \033[0m


## Pythonic variables
# It's a good idea to avoid hardcoding tool executables in a Makefile.
# Setting them with ?= enables override, e.g. `make deps PYENV=path/to/dev/pyenv`
VENV := .venv
PYENV ?= pyenv
BASE_REQ := requirements-base.txt
RUFF_CONF_FILE := ruff.toml
PRECOMMIT_CONF_FILE := .pre-commit.yaml
TESTS_BASE_DIR := tests
TEST_COV_THRESHOLD := 60
INSTALL_STAMP := $(VENV)/.install.stamp
CURRENT_PYTHON ?= $(VENV)/bin/python
RUFF ?= $(CURRENT_PYTHON) run ruff
BLACK ?= $(VENV)/bin/black
PYTEST ?= $(CURRENT_PYTHON) -m pytest
PIP := $(VENV)/bin/pip


##@ Utility
.DEFAULT_GOAL := help

.PHONY: help
help: ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: debug-make
debug-make: ## Shows ~all runtime-set variables
	@echo $(foreach v, $(.VARIABLES), $(info $(v) = $($(v))))

###
### TASKS
###

##@ Virtual Enrionment

.PHONY: venv # Check if virtual environment exists or create a new one
venv:
	@if [ ! -d "$(VENV)" ]; then \
		echo "$(COLOR_BLUE)Creating new virtual environment...$(COLOR_RESET)"; \
		(python -m venv $(VENV)); \
	else \
		echo "$(COLOR_GREEN)Virtual environment already exists$(COLOR_RESET)"; \
	fi


.PHONY: activate # Active virtual environment
activate:
	@if [ -z "$$VIRTUAL_ENV" ]; then \
		echo "$(COLOR_GREEN)Activating virtual environment...$(COLOR_RESET)"; \
		(. $(VENV)/bin/activate); \
	fi

##@ Dependencies
.PHONY: make-env
make-env: venv activate start-base-project install-base-deps ## Create virtual env, activate and install requirements.txt
	@echo "$(COLOR_GREEN)Virtual environmen was created and base deps was installed$(COLOR_RESET)"; \
	(\
      python -c 'import sys; print(sys.prefix)'; \
      pip -V \
    )

.PHONY: start-base-project 
start-base-project: ## Clone base requirements.txt
	@if [ ! -f "$(BASE_REQ)" ]; then \
		echo "$(COLOR_BLUE)Getting Base requirements.txt...$(COLOR_RESET)"; \
		curl https://gist.githubusercontent.com/mabittar/51b87299a4fe69ceae8ead218ceb71e1/raw/2a16b7e58f95f74a25daf06bbd00e10a3d21588b/requirements-base.txt > ./$(BASE_REQ); \
	else \
		echo "$(COLOR_GREEN)Base requirements already exists$(COLOR_RESET)"; \
	fi	
	@if [ ! -f "$(RUFF_CONF_FILE)" ]; then \
		echo "$(COLOR_BLUE)Getting ruff config file...$(COLOR_RESET)"; \
		curl https://gist.githubusercontent.com/mabittar/51b87299a4fe69ceae8ead218ceb71e1/raw/297f0ef0580172befef251a956ecb83dadae03a6/ruff.toml > ./$(RUFF_CONF_FILE); \
	else \
		echo "$(COLOR_GREEN)Ruff config already exists$(COLOR_RESET)"; \
	fi
	@if [ ! -f "$(PRECOMMIT_CONF_FILE)" ]; then \
		echo "$(COLOR_BLUE)Getting ruff config file...$(COLOR_RESET)"; \
		curl https://gist.githubusercontent.com/mabittar/51b87299a4fe69ceae8ead218ceb71e1/raw/297f0ef0580172befef251a956ecb83dadae03a6/pre-commit-config.yaml > ./$(PRECOMMIT_CONF_FILE); \
	else \
		echo "$(COLOR_GREEN)Pre-commit config already exists$(COLOR_RESET)"; \
	fi

.PHONY: install-base-deps 
install-base-deps: ## Install base requirements, ruff config and pre-commit
	@if [ -d ".git" ]; then \
	$(MAKE) install-precommit; \
	else \
		echo "$(COLOR_RED)Git repository is not initialized. Skip pre-commit install.$(COLOR_RESET)"; \
	fi
	($(PIP) install --upgrade pip)
	($(PIP) install -r $(BASE_REQ))


.PHONY: pip-install
pip-install: activate ## Upgrade pip and install dependencies in virtual env
	($(PIP) install --upgrade pip)
	($(PIP) install -r requirements.txt)


.PHONY: deps
deps: deps-py install-precommit ## Installs all dependencies
	@echo "$(COLOR_GREEN)All deps installed!$(COLOR_RESET)"

.PHONY: deps-py
deps-py: install-python  ## Install Python-based dependencies
	@echo "$(COLOR_GREEN)All Python deps installed!$(COLOR_RESET)"

.PHONY: deps-py-update
deps-py-update: poetry-update ## Update Poetry deps, e.g. after adding a new one manually
	@echo "$(COLOR_GREEN)All Python deps updated!$(COLOR_RESET)"

.PHONY: install-python
install-python: $(PYTHON_EXEC) ## Installs appropriate Python version
	@echo "$(COLOR_GREEN)Python installed to $(PYTHON_EXEC)$(COLOR_RESET)"

.PHONY: install-deps ## Install package dependencies
SITE_PACKAGES := $(shell pip show pip | grep '^Location' | cut -f2 -d':')
install: $(SITE_PACKAGES)

$(SITE_PACKAGES): requirements.txt
	($(PIP) install -r requirements.txt)

.PHONY: update-req
update-req: ## Export requirements to requirements.txt
	($(VENV)/bin/pip freeze > ./requirements.txt)


##@ Manual Setup

# file(s) written by pre-commit setup
GIT_HOOKS = .git/hooks/pre-commit
.PHONY: install-precommit
install-precommit:  ## Sets up pre-commit hooks
	@echo "$(COLOR_GREEN)Pre-commit configured, will run on future commits!$(COLOR_RESET)"

$(GIT_HOOKS): .pre-commit-config.yaml
	pre-commit install


##@ Tests

.PHONY: test-cov ## Run converage test 
test-cov: $(INSTALL_STAMP) 
	$(PYTHON) -m pytest ./$(TESTS_BASE_DIR)/ --cov-report term-missing --cov-fail-under $(TEST_COV_THRESHOLD) --cov

.PHONY: test-all
test-all: test-unittests test-integration  ## Run all tests
	@echo "$(COLOR_GREEN)$(MAKECMDGOALS) succeeded$(COLOR_RESET)"

# If you mark tests, you can switch to using the marks by swapping the
# commented lines in the next two tasks.

.PHONY: test-unittests
test-unittests: ## Run unit tests
	$(PYTEST) $(TESTS_BASE_DIR)/unit
# $(PYTEST) tests -m unittest

.PHONY: test-integration
test-integration: ## Run integration tests
	$(PYTEST) $(TESTS_BASE_DIR)/integration
# $(PYTEST) tests -m integration

##@ Development

.PHONY: lint
lint: isort check-py-ruff-fix check-py-black ## Sort import, run ruff and check black

.PHONY: isort 
isort: ## Sort imports
	$(VENV)/bin/isort --profile=black --lines-after-imports=2 --check-only ./tests/ $(NAME) --virtual-env=$(VENV)

.PHONY: check
check: check-py-ruff-format check-py-ruff-lint check-precommit ## Run all checks

.PHONY: check-py-ruff-lint
check-py-ruff-lint: ## Run ruff linter
	$(RUFF) $(RUFF_OPTS) $(MODULE_BASE_DIR) $(TESTS_BASE_DIR) || \
		(echo "$(COLOR_RED)Run '$(notdir $(MAKE)) check-py-ruff-fix' to fix some of these automatically if [*] appears above, then run '$(notdir $(MAKE)) $(MAKECMDGOALS)' again." && false)

.PHONY: check-py-ruff-fix
check-py-ruff-fix: ## Run ruff linter
	$(MAKE) check-py-ruff-lint RUFF_OPTS=--fix

.PHONY: check-py-black
check-py-black: ## Runs black code formatter
	$(BLACK) --check --fast .

.PHONY: check-py-ruff-format
check-py-ruff-format: ## Runs ruff code formatter
	$(RUFF) $(RUFF_OPTS) format --check .


.PHONY: check-precommit
check-precommit: ## Runs pre-commit on all files
	pre-commit run --all-files

.PHONY: format-py
format-py: ## Runs formatter, makes changes where necessary
	$(RUFF) format .

##@ Miscellaneous

.PHONY: clean
clean: ## Clean artifacts from build and dist directories, virtual env and others cache files
	rm -rf $(BUILD_DIR) $(VENV)
	find -iname "*.pyc" -delete
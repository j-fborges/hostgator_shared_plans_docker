# HostGator Matching Development Environment (Docker)

This repository provides a **reproducible Docker-based development environment** that closely mimics the **HostGator shared hosting** setup so developers can Pre-Bundle and fully package entire Ruby projects with Gems (Or Python packages) before shipping. It allows you to run a Rails 5.0.5 application with Ruby 2.4.10, MySQL 5.7, and all necessary dependencies in an isolated container, while keeping your project files safely on your host machine.

## Purpose

Primarily the goal is to provide an environment for developers where they can Pre-Bundle and fully package entire Ruby projects with Gems (Or Python packages) that require compilation so they can ship it to the shared hosting plan and just execute it (Since you wont be able to compile locally within Shared Hosting Plans). By using this Docker environment, you can:

- Develop and test your Rails application locally in an environment identical to HostGator’s production servers.
- Avoid conflicts with system Ruby versions or installed gems.
- Quickly onboard new team members – just clone the repo and run one script.
- Keep multiple projects isolated and switch between them effortlessly.

## Environment Details

The environment is built on **CentOS 7** and includes the following software with exact versions to match HostGator’s production stack:

| Component          | Version                                     | Notes                                   |
|--------------------|---------------------------------------------|-----------------------------------------|
| Base OS            | CentOS 7 (official image)                   |                                         |
| Ruby               | 2.4.10 (compiled from source)               | Exactly matches HostGator’s EA Ruby 24  |
| Bundler            | 2.3.27                                       |                                         |
| RubyGems           | 2.6.14.4                                     |                                         |
| MySQL              | 5.7.44                                       | Client libraries and devel headers      |
| OpenSSL            | 1.0.2k                                       |                                         |
| Node.js            | Not included (use therubyracer for JS)       |                                         |
| JavaScript runtime | `therubyracer` (0.12.3) with V8 3.16         | Provides ExecJS support without Node.js |
| Web server         | Puma / Passenger (depending on your Gemfile) |                                         |
| Additional tools   | git, curl, wget, zip, unzip, make, gcc, etc. |                                         |

The Docker image is built from the provided `Dockerfile` and includes all the build tools needed to compile native gems (like `mysql2`, `nokogiri`, `therubyracer`).

## Features

- **Workspace isolation** – Your projects live in the `workspace/` folder, which is mounted into the container at `${APP_ROOT}${RAILS_PROJECTS_FOLDER}`. The folder itself is tracked in git (via `.gitkeep`), but its contents are ignored – perfect for storing multiple projects.
- **One‑click setup** – Run `./bin/setup.sh` to build the image, start the containers, and prepare the database.
- **Easy shell access** – `./bin/start.sh` starts the environment and drops you directly into a bash shell inside the app container.
- **Clean teardown** – `./bin/destroy.sh` removes **all** containers, volumes, and images, giving you a completely fresh start.
- **Persistent data** – MySQL data is stored in a Docker volume; use the destroy script with caution if you want to wipe it.
- **Flexible project handling** – Clone any number of Rails applications into `workspace/` and run them without rebuilding the image.

## Prerequisites

- **Docker** (version 20.10 or higher) and **Docker Compose** (v2) installed on your system.  
  [Get Docker](https://docs.docker.com/get-docker/)
- Basic familiarity with the command line.

## Getting Started

1. **Clone this repository**  
   ```bash
   git clone <repository-url> hostgator-env
   cd hostgator-env

2. **Run the setup script**  
   ```bash
   ./bin/setup.sh
   ```
   This will:
   - Build the Docker image.
   - Start the containers (app, MySQL, PHP if defined).
   - Run `rails db:create db:migrate db:seed` inside the container (if your app is present).

3. **Start the environment and enter the container**  
   ```bash
   ./bin/start.sh
   ```
   You’ll be placed in a bash shell inside the app container, with your project already mounted at `${APP_ROOT}${RAILS_PROJECTS_FOLDER}`.

4. **Run your Rails server**  
   Inside the container:
   ```bash
   bundle exec rails s -b 0.0.0.0
   ```
   Now open your browser to `http://localhost:3000` – your app should be live!

## Environment Configuration (.env)

The environment uses a `.env` file for dynamic configuration of paths and other settings. This allows you to customize where your Rails applications reside inside the container and which host folder is mounted.

Create a `.env` file in the project root (use `.env.example` as a template) with the following variables:

| Variable             | Description                                                                            | 
|----------------------|----------------------------------------------------------------------------------------|
| APP_ROOT             | Base path inside the container where Ruby gems and application code will live.         |
| RAILS_PROJECTS_FOLDER| Subfolder under APP_ROOT where your Rails app will be mounted.                         |
| HOST_WORKSPACE       | Path on your host machine that contains your Rails projects (defaults to ./workspace). |

**Important:** The `.env` file is ignored by git (see `.gitignore`) to keep secrets and local paths out of version control. An example file `.env.example` is provided for reference.

After setting your desired paths, run the setup script and everything will adapt automatically.

## Scripts Reference

All management scripts are located in the `bin/` directory. Make them executable with `chmod +x bin/*.sh` if needed.

| Script                 | Description                                                                                  |
|------------------------|----------------------------------------------------------------------------------------------|
| `setup.sh`             | Full initial setup: builds images, starts containers, runs database setup.                   |
| `start.sh`             | Starts the environment and opens a bash shell in the app container.                          |
| `stop.sh`              | Stops all containers gracefully (without removing them).                                     |
| `destroy.sh`           | **Destructive**: stops and removes containers, volumes, and all images used by this project. |
| `mount-workspace.sh`   | Creates the `workspace/` folder (if missing) and adds a `.gitkeep` file. Usually run once.   |

## Workspace Handling

The `workspace/` folder is where you store your Rails applications.

- **The folder itself is tracked in git** (via an empty `.gitkeep` file).
- **All contents of `workspace/` are ignored** (see `.gitignore`), so you can freely add, remove, or modify projects without polluting the repository.

This design lets you keep multiple independent projects while sharing the same Docker environment. For example:

workspace/
├── project-alpha/
├── project-beta/
└── legacy-app/

To use a specific project, simply mount it into the container – our `docker-compose.yml` already mounts `./workspace` to the container’s working directory, so any subfolder is accessible.

## Customizing the Environment

- **Ports**: The app container exposes port `3000` by default. If you need to change it, edit `docker-compose.yml`.
- **Database credentials**: The MySQL service uses default credentials (root / no password). You can override them via environment variables in `docker-compose.yml` or a `.env` file (see `.env.example`).
- **Additional services**: The Compose file also includes a PHP 7.4 container (for any legacy PHP integration). You can remove or modify it as needed.

## Troubleshooting

| Problem                                      | Possible Solution                                                                                   |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------|
| `Gem::Ext::BuildError` when installing gems  | Ensure your Gemfile uses compatible gem versions (e.g., `nokogiri ~> 1.8.5`).                       |
| “Could not find a JavaScript runtime”        | The environment includes `therubyracer`. Make sure your Gemfile has `gem 'therubyracer', '0.12.3'`. |
| Container exits immediately                   | Check logs with `docker compose logs app`. Usually a missing Gemfile or bundler error.              |
| Permission denied when writing files          | Files created inside the container will be owned by root. Use `chown` on the host if needed.        |
| Port 3000 already in use                      | Stop the conflicting service or change the host port in `docker-compose.yml`.                       |

## Contributing

If you improve this environment (e.g., add more matching HostGator packages), feel free to submit a pull request. Please keep the focus on reproducibility and clarity.

## License

This project is provided as-is under the MIT License. See [LICENSE](LICENSE) for details.
# Instructions

This project assumes that you have installed Python (>= 3.5) and pip. The use of pyenv and pyenv-virtualenv is recommended for linux/mac users.

1. Start the Alfalfa containers. The code will only start one worker node along with the required server services.

    ```
    cd <alfalfa-checkout-root>
    docker-compose up
    ```
1. Install the dependencies

    ```
    cd <this-checkout-root>
    pip install poetry

    # Note if a github dependency is not updating then run
    poetry install
    ```

1. Run one of the example projects

    ```
    python rl_fmu_simple_1_zone_heating.py

    # or openstudio
    python rl_osm_base.py
    ```

# Debugging

## Minio

* http://localhost:9000
* The default login is "user" and "password"
* Navigate to uploads

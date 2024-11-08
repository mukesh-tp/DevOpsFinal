pipeline {
    agent any
    environment {
        BLUE_PORT = '8081'
        GREEN_PORT = '8082'
        NGINX_CONF = '/etc/nginx/sites-available/default'
        CURRENT_ENV = ''
        NEW_ENV = ''
        NEW_PORT = ''
    }
    stages {
        stage('Determine Target Environment') {
            steps {
                script {
                    // Check the currently active environment
                    def currentEnv = sh(script: "curl -s http://localhost:8083 | grep -o 'Blue\\|Green'", returnStdout: true).trim()
                    CURRENT_ENV = currentEnv ?: 'Blue'
                    echo "Currently active environment: ${CURRENT_ENV}"

                    // Determine new environment to deploy
                    NEW_ENV = CURRENT_ENV == 'Blue' ? 'green-app' : 'blue-app'
                    NEW_PORT = CURRENT_ENV == 'Blue' ? GREEN_PORT : BLUE_PORT
                    echo "Switching to environment: ${NEW_ENV}"
                }
            }
        }
        stage('Pull Latest Code') {
            steps {
                git 'https://github.com/mukesh-tp/DevOpsFinal.git'
            }
        }
        stage('Deploy to New Environment') {
            steps {
                sh "docker-compose up -d ${NEW_ENV}"
            }
        }
        stage('Health Check') {
            steps {
                script {
                    def statusCode = sh(script: "curl -s -o /dev/null -w '%{http_code}' http://localhost:${NEW_PORT}", returnStdout: true).trim()
                    if (statusCode != "200") {
                        error("Health check failed for ${NEW_ENV} on port ${NEW_PORT}!")
                    }
                }
            }
        }
        stage('Switch Traffic') {
            steps {
                script {
                    // Edit the Nginx configuration file to switch traffic
                    def newUpstream = NEW_PORT == '8081' ? 'localhost:8081' : 'localhost:8082'
                    sh """
                        sudo sed -i 's/server localhost:8081;/server ${newUpstream};/' ${NGINX_CONF}
                        sudo sed -i 's/server localhost:8082;/server ${newUpstream};/' ${NGINX_CONF}
                        sudo systemctl reload nginx
                    """
                    echo "Switched traffic to ${NEW_ENV} on port ${NEW_PORT}"
                }
            }
        }
        stage('Clean Up Old Environment') {
            steps {
                script {
                    def oldEnv = CURRENT_ENV.toLowerCase() + "-app"
                    sh "docker-compose down ${oldEnv}"
                }
            }
        }
    }
}


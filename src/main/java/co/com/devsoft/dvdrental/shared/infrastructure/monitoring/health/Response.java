package co.com.devsoft.dvdrental.shared.infrastructure.monitoring.health;

public record Response(String id, String status, String secret) {
    public Response {
        if (id == null || id.trim().isEmpty()) {
            throw new IllegalArgumentException("id variable can not be null or empty...");
        }

        if (status == null || status.trim().isEmpty()) {
            throw new IllegalArgumentException("status variable can not be null or empty...");
        }

        if (secret == null || secret.trim().isEmpty()) {
            throw new IllegalArgumentException("secret variable can not be null or empty...");
        }
    }
}

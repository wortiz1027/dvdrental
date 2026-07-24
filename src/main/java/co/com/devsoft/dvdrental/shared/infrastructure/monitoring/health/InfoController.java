package co.com.devsoft.dvdrental.shared.infrastructure.monitoring.health;

import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import lombok.extern.log4j.Log4j2;

@Log4j2
@RestController
@RequestMapping(value = "/api")
public class InfoController {

    @GetMapping(path = "/info/{id}", consumes = "application/json", produces = "application/json")
    public ResponseEntity<Response> getInfo(@RequestHeader Map<String, String> headers, @PathVariable String id) {
        headers.forEach((key, value) -> {
            log.info(String.format("Header -> {%s}: {%s}", key, value));
        });

        return ResponseEntity.ok().header("x-secret-key", "ready")
                .body(new Response(id, "UP", headers.get("x-secret-key")));
    }

}

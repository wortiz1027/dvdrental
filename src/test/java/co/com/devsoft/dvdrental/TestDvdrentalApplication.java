package co.com.devsoft.dvdrental;

import org.springframework.boot.SpringApplication;

public class TestDvdrentalApplication {

  public static void main(String[] args) {
    SpringApplication.from(DvdrentalApplication::main)
        .with(TestcontainersConfiguration.class)
        .run(args);
  }
}

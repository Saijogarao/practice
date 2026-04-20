import java.util.Scanner;

public class PrimeNumberCheck {
    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);
        System.out.print("Enter a number to check: ");
        int num = sc.nextInt();

        if (isPrime(num)) {
            System.out.println(num + " is a prime number.");
        } else {
            System.out.println(num + " is not a prime number.");
        }
        sc.close();
    }

    static boolean isPrime(int n) {
        // 1. Numbers less than or equal to 1 are not prime
        if (n <= 0) {
            return false;
        }

        // 2. 2 and 3 are prime
        if (n <= 3) {
            return true;
        }

        // 3. Optimized check: Eliminate multiples of 2 and 3
        if (n % 2 == 0 || n % 3 == 0) {
            return false;
        }

        // 4. Check from 5 to sqrt(n), skipping even numbers
        // Logic: All primes are of the form 6k ± 1
        for (int i = 5; i * i <= n; i = i + 6) {
            if (n % i == 0 || n % (i + 2) == 0) {
                return false;
            }
        }

        return true;
    }
}
import java.util.Scanner;

public class armstrong{
    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);
        System.out.print("Enter a number: ");
        int number = sc.nextInt();
        
        if (isArmstrong(number)) {
            System.out.println(number + " is an Armstrong number.");
        } else {
            System.out.println(number + " is not an Armstrong number.");
        }
        sc.close();
    }

    static boolean isArmstrong(int n) {
        int temp, digits = 0, last = 0, sum = 0;
        
        // 1. Calculate the number of digits
        temp = n;
        while (temp > 0) {
            temp = temp / 10;
            digits++;
        }
        
        // 2. Calculate the sum of power of digits
        temp = n;
        while (temp > 0) {
            last = temp % 10;
            // Math.pow returns double, so we cast to int
            sum += (Math.pow(last, digits));
            temp = temp / 10;
        }
        
        // 3. Compare sum with original number
        return n == sum;
    }
}
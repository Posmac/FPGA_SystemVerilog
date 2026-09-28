module blink (
    input  i_clk,   // Системный клок 25 МГц (кварц на плате)
    output o_led    // Выход на светодиод D2
);

    // Счетчик для деления частоты. 
    // Нам нужно отсчитать 25 000 000 тактов, чтобы прошла ровно 1 секунда.
    // 25 миллионов в двоичной системе занимает 25 бит, поэтому берем [24:0]
    reg [24:0] r_clk_counter = 0;
    reg        r_led_state   = 0;

    // Привязываем состояние светодиода к нашему регистру
    assign o_led = r_led_state;

    always @(posedge i_clk) begin
        if (r_clk_counter < 25000000 - 1) begin
            r_clk_counter <= r_clk_counter + 1;
        end else begin
            r_clk_counter <= 0;
            r_led_state   <= ~r_led_state; // Инвертируем состояние (был 0 -> станет 1, и наоборот)
        end
    end

endmodule

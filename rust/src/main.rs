use std::convert::TryInto;
use std::io::{self, Read, Write};
use std::time::Duration;

// Константы протокола FPGA
const PACKET_SIZE: usize = 16;
const STX: u8 = 0x02;
const EXPECTED_LEN_BYTE: u8 = 0x10;

#[derive(Debug)]
struct AluResult {
    param_a: u32,
    param_b: u32,
    result: u32,
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let port_name = "/dev/cu.usbmodem102";
    let mut port = serialport::new(port_name, 115_200)
        .timeout(Duration::from_millis(50))
        .open()?;

    // ==========================================
    // 1. ПОДГОТОВКА И ОТПРАВКА КОМАНДЫ НА FPGA
    // ==========================================

    // Задаем параметры прямо в Rust
    let opcode: u8 = 0; // 0 для ADD
    let param_a: u32 = 1; // Первый параметр
    let param_b: u32 = 1; // Второй параметр

    // Собираем бинарный пакет (ваши 10 байт):
    // 1 байт opcode + 1 байт (видимо длина/флаг) + 4 байта A + 4 байта B
    let mut tx_buffer = Vec::new();
    tx_buffer.push(opcode);
    tx_buffer.push(2); // По вашему дампу [0, 2, ...] Второй байт равен 2
    tx_buffer.extend_from_slice(&param_a.to_le_bytes()); // Little-endian байты
    tx_buffer.extend_from_slice(&param_b.to_le_bytes());

    println!("Отправка команды на FPGA: {:02X?}", tx_buffer);

    // ОТПРАВЛЯЕМ В ПОРТ
    port.write_all(&tx_buffer)?;
    port.flush()?; // Важно на macOS! Принудительно выталкивает байты в USB-провод

    println!("Команда ушла. Ожидание ответа от АЛУ...");

    // ==========================================
    // 2. ЦИКЛ ОЖИДАНИЯ И ПАРСИНГА ОТВЕТА
    // ==========================================
    let mut read_buffer: [u8; 256] = [0; 256];
    let mut raw_bytes = Vec::new();

    loop {
        match port.read(&mut read_buffer) {
            Ok(bytes_read) if bytes_read > 0 => {
                raw_bytes.extend_from_slice(&read_buffer[..bytes_read]);

                // Проверяем, набралось ли 16 байт ответа
                while raw_bytes.len() >= PACKET_SIZE {
                    // Ищем маркер начала STX (0x02)
                    if raw_bytes[0] != STX {
                        raw_bytes.remove(0);
                        continue;
                    }

                    // Проверяем второй байт длины (0x10)
                    if raw_bytes[1] != EXPECTED_LEN_BYTE {
                        raw_bytes.remove(0);
                        continue;
                    }

                    // Проверяем маркеры конца пакета (\n\r)
                    if raw_bytes[PACKET_SIZE - 2] != 0x0A || raw_bytes[PACKET_SIZE - 1] != 0x0D {
                        raw_bytes.remove(0);
                        continue;
                    }

                    // Пакет валиден, забираем его из буфера
                    let packet: Vec<u8> = raw_bytes.drain(..PACKET_SIZE).collect();

                    // Вырезаем полезную нагрузку (12 байт между заголовком и хвостом)
                    let payload = &packet[2..14];

                    // Распаковываем данные
                    let res_a = u32::from_le_bytes(payload[0..4].try_into().unwrap());
                    let res_b = u32::from_le_bytes(payload[4..8].try_into().unwrap());
                    let result = u32::from_le_bytes(payload[8..12].try_into().unwrap());

                    let alu_data = AluResult {
                        param_a: res_a,
                        param_b: res_b,
                        result,
                    };

                    println!("\n✅ [Успех! Ответ от FPGA АЛУ]");
                    println!("Операция  : ADD (Opcode {})", opcode);
                    println!("Вход А    : {}", alu_data.param_a);
                    println!("Вход Б    : {}", alu_data.param_b);
                    println!("Результат : {}", alu_data.result);
                    println!("--------------------------------");

                    return Ok(()); // Выходим из программы после получения результата
                }
            }
            Err(ref e) if e.kind() == io::ErrorKind::TimedOut => {
                // Если FPGA еще считает или не ответила, продолжаем ждать
                continue;
            }
            Err(e) => {
                eprintln!("Ошибка порта: {}", e);
                break;
            }
            _ => {}
        }
    }

    Ok(())
}

# Portal de Termos

Pacote de instalação do **Portal de Termos DICASA** para Linux.

O sistema permite controlar:

- Termos de responsabilidade;
- Entrega de equipamentos, smartphones e chips;
- Devoluções;
- Ocorrências de dano ou extravio;
- Assinaturas digitais;
- Anexos opcionais;
- Materiais cadastrados e histórico de uso;
- Personalização de cores e assinatura do responsável de TI.

---

## Arquivos do repositório

| Arquivo | Descrição |
|---|---|
| `portal-termos.tar.gz` | Pacote completo da aplicação para Linux |
| `portal-termos.tar.gz.sha256` | Arquivo para validação da integridade do pacote |
| `instalar.sh` | Script automático para baixar e instalar o Portal |

---

## Instalação rápida

Execute como `root` ou usando `sudo`:

```bash
curl -fsSL https://raw.githubusercontent.com/antoniocarlosbotelho/portal-termos/main/instalar.sh | sudo bash

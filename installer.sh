#!/bin/bash
#
# 🧊 ColdCare Raspberry Pi — Installer automatico (per eseguibili compilati)
#

set -e

echo "============================================================"
echo "🚀 ColdCare Raspberry Pi — Installazione automatica"
echo "============================================================"
echo

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

# 🧱 Controllo permessi
if [[ $EUID -ne 0 ]]; then
   echo "❌ Devi eseguire questo script come root."
   echo "   Usa: sudo ./installer.sh"
   exit 1
fi

# 📦 File richiesti (tutti eseguibili compilati)
REQUIRED_FILES=("printer" "alert_dispatcher" "app" "raspberry_coldcare_client" "raspberry_quick_setup_compiled")

echo "🔍 Controllo file richiesti..."
for file in "${REQUIRED_FILES[@]}"; do
  if [[ ! -f "$BASE_DIR/$file" ]]; then
    echo "❌ File mancante: $file"
    echo "   Assicurati di aver estratto correttamente il pacchetto ZIP."
    exit 1
  fi
done
echo "✅ Tutti i file presenti."
echo

# ⚙️ Rende eseguibili i binari
echo "⚙️ Imposto i permessi di esecuzione..."
chmod +x "$BASE_DIR"/*
echo "✅ Permessi impostati."
echo

# 📥 Copia i binari in /usr/local/bin
echo "📦 Installazione eseguibili in /usr/local/bin ..."
cp "$BASE_DIR"/printer "$BASE_DIR"/alert_dispatcher "$BASE_DIR"/app "$BASE_DIR"/raspberry_coldcare_client "$BASE_DIR"/raspberry_quick_setup_compiled /usr/local/bin/
chmod +x /usr/local/bin/{printer,alert_dispatcher,app,raspberry_coldcare_client,raspberry_quick_setup_compiled}
echo "✅ Eseguibili installati."
echo

# 🔎 Verifica visibilità
echo "🔎 Verifica eseguibili..."
for bin in printer alert_dispatcher app raspberry_coldcare_client raspberry_quick_setup_compiled; do
    if ! command -v $bin &>/dev/null; then
        echo "❌ Eseguibile $bin non trovato nel PATH!"
        exit 1
    fi
done
echo "✅ Tutti gli eseguibili sono raggiungibili."
echo

# 🚀 Avvia il setup ColdCare (compilato)
echo "🚀 Avvio setup ColdCare..."
raspberry_quick_setup_compiled
echo

# 🔁 Riavvio servizi systemd
echo "🔁 Riavvio servizi systemd..."
systemctl daemon-reload || true
for svc in coldcare_client printer_service alert_dispatcher coldcare_webapp; do
    if systemctl list-unit-files | grep -q "$svc"; then
        systemctl enable "$svc"
        systemctl restart "$svc"
        echo "✅ Servizio $svc avviato"
    fi
done
echo

echo "============================================================"
echo "🎉 INSTALLAZIONE COMPLETATA!"
echo "============================================================"
echo "📱 ColdCare è stato installato con successo."
echo "💡 Puoi verificare lo stato dei servizi con:"
echo "   sudo systemctl status coldcare_client"
echo
echo "🌐 Verifica la connessione su https://coldcare.it/admin"
echo "============================================================"

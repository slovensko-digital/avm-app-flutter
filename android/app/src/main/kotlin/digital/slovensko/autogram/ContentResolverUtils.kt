package digital.slovensko.autogram

import android.content.ContentResolver
import android.net.Uri
import android.provider.OpenableColumns

/** Returns the "Display name" for given [uri]. */
internal fun ContentResolver.getDisplayName(uri: Uri): String? {
    return query(uri, null, null, null, null)?.use { cursor ->
        if (cursor.moveToFirst()) {
            // mime_type
            // _size
            val index = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)

            if (index != -1) {
                return@use cursor.getString(index)
            }
        }
        null
    }
}
